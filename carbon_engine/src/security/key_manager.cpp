#include "carbon/key_manager.hpp"
#include <openssl/evp.h>
#include <openssl/x509.h>
#include <openssl/x509v3.h>
#include <openssl/pem.h>
#include <openssl/pkcs12.h>
#include <fstream>
#include <regex>

namespace carbon::security {

KeyManager::KeyManager(fs::path project_root) : project_root_(std::move(project_root)) {}
KeyManager::~KeyManager() = default;

static std::string extract_der_hex_from_pem(const fs::path& pem_path) {
    FILE* fp = fopen(pem_path.c_str(), "r");
    if (!fp) return "";

    X509* cert = PEM_read_X509(fp, nullptr, nullptr, nullptr);
    fclose(fp);
    if (!cert) return "";

    unsigned char* der = nullptr;
    int len = i2d_X509(cert, &der);
    X509_free(cert);

    if (len <= 0 || !der) return "";

    std::string hex = to_hex(der, static_cast<size_t>(len));
    OPENSSL_free(der);
    return hex;
}

CarbonResult<KeyBundle> KeyManager::DiscoverActiveKeys(const std::optional<fs::path>& custom_keys_dir) {
    KeyBundle bundle;

    // 1. Caminho customizado da CLI
    if (custom_keys_dir && fs::exists(*custom_keys_dir)) {
        fs::path p_pk8 = *custom_keys_dir / "platform.pk8";
        fs::path p_pem = *custom_keys_dir / "platform.x509.pem";
        if (fs::exists(p_pk8) && fs::exists(p_pem)) {
            bundle.profile = KeyProfile::DEVELOPER_RELEASE_KEYS;
            bundle.platform_pk8 = p_pk8;
            bundle.platform_pem = p_pem;
            bundle.platform_der_hex = extract_der_hex_from_pem(p_pem);
            return bundle;
        }
    }

    // 2. Chaves privadas em security/keys/
    fs::path sec_dir = project_root_ / "security" / "keys";
    fs::path p_pk8 = sec_dir / "platform.pk8";
    fs::path p_pem = sec_dir / "platform.x509.pem";
    if (fs::exists(p_pk8) && fs::exists(p_pem)) {
        bundle.profile = KeyProfile::OFFICIAL_CARBON_KEYS;
        bundle.platform_pk8 = p_pk8;
        bundle.platform_pem = p_pem;
        bundle.platform_der_hex = extract_der_hex_from_pem(p_pem);
        return bundle;
    }

    // 3. Fallback AOSP
    fs::path aosp_dir = project_root_ / "carbon_ours" / "security_keys";
    if (!fs::exists(aosp_dir)) {
        aosp_dir = project_root_ / "security";
    }

    fs::path aosp_pk8 = aosp_dir / "aosp_platform.pk8";
    fs::path aosp_pem = aosp_dir / "aosp_platform.x509.pem";

    if (fs::exists(aosp_pk8) && fs::exists(aosp_pem)) {
        bundle.profile = KeyProfile::AOSP_TEST_KEYS_FALLBACK;
        bundle.platform_pk8 = aosp_pk8;
        bundle.platform_pem = aosp_pem;
        bundle.platform_der_hex = extract_der_hex_from_pem(aosp_pem);
        return bundle;
    }

    return CarbonError(ErrorCode::ERR_KEY_INVALID, "Nenhuma chave de plataforma valida encontrada");
}

CarbonResult<void> KeyManager::GenerateNewKeyPair(const fs::path& output_dir, 
                                                 const std::string& org_name, 
                                                 const std::string& common_name) {
    std::error_code ec;
    fs::create_directories(output_dir, ec);

    // Gera chave RSA 4096-bit
    EVP_PKEY* pkey = EVP_RSA_gen(4096);
    if (!pkey) {
        return CarbonResult<void>::err(ErrorCode::ERR_KEY_INVALID, "Failed to generate RSA 4096-bit key");
    }

    // Create self-signed X.509 certificate
    X509* x509 = X509_new();
    ASN1_INTEGER_set(X509_get_serialNumber(x509), 1);
    X509_gmtime_adj(X509_get_notBefore(x509), 0);
    X509_gmtime_adj(X509_get_notAfter(x509), 315360000L); // 10000 days (~27 years)

    X509_set_pubkey(x509, pkey);

    X509_NAME* name = const_cast<X509_NAME*>(X509_get_subject_name(x509));
    X509_NAME_add_entry_by_txt(name, "C", MBSTRING_ASC, reinterpret_cast<const unsigned char*>("BR"), -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "O", MBSTRING_ASC, reinterpret_cast<const unsigned char*>(org_name.c_str()), -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "CN", MBSTRING_ASC, reinterpret_cast<const unsigned char*>(common_name.c_str()), -1, -1, 0);
    X509_set_issuer_name(x509, name);

    if (X509_sign(x509, pkey, EVP_sha256()) <= 0) {
        X509_free(x509);
        EVP_PKEY_free(pkey);
        return CarbonResult<void>::err(ErrorCode::ERR_KEY_INVALID, "Failed to sign X.509 certificate");
    }

    // Grava platform.x509.pem
    fs::path pem_path = output_dir / "platform.x509.pem";
    FILE* fp_pem = fopen(pem_path.c_str(), "w");
    if (fp_pem) {
        PEM_write_X509(fp_pem, x509);
        fclose(fp_pem);
    }

    // Grava platform.pk8 (PKCS#8 DER sem senha, padrao signapk)
    fs::path pk8_path = output_dir / "platform.pk8";
    BIO* bio_pk8 = BIO_new_file(pk8_path.c_str(), "wb");
    if (bio_pk8) {
        i2d_PKCS8PrivateKey_bio(bio_pk8, pkey, nullptr, nullptr, 0, nullptr, nullptr);
        BIO_free(bio_pk8);
    }

    X509_free(x509);
    EVP_PKEY_free(pkey);

    return CarbonResult<void>::ok();
}

CarbonResult<void> KeyManager::InjectPlatformSignature(const fs::path& decoded_services_dir, 
                                                      const std::string& platform_der_hex) {
    if (!fs::exists(decoded_services_dir)) {
        return CarbonResult<void>::err(ErrorCode::ERR_INVALID_ARGUMENT, "Diretorio de services.jar descompilado inexistente");
    }

    // Localiza InstallPackageHelper.smali recursivamente
    fs::path target_smali;
    std::error_code ec;
    for (const auto& entry : fs::recursive_directory_iterator(decoded_services_dir, ec)) {
        if (entry.path().filename() == "InstallPackageHelper.smali") {
            target_smali = entry.path();
            break;
        }
    }

    if (target_smali.empty()) {
        return CarbonResult<void>::err(ErrorCode::ERR_NODE_NOT_FOUND, "InstallPackageHelper.smali not found in " + decoded_services_dir.string());
    }

    std::ifstream in(target_smali);
    if (!in.is_open()) {
        return CarbonResult<void>::err(ErrorCode::ERR_HASH_IO_ERROR, "Cannot open smali file for reading");
    }

    std::string content((std::istreambuf_iterator<char>(in)), std::istreambuf_iterator<char>());
    in.close();

    const std::string placeholder = "CONFIG_CUSTOM_PLATFORM_SIGNATURE";
    size_t pos = content.find(placeholder);
    if (pos == std::string::npos) {
        // Already injected or not found
        return CarbonResult<void>::ok();
    }

    content.replace(pos, placeholder.length(), platform_der_hex);

    std::ofstream out(target_smali, std::ios::trunc);
    if (!out.is_open()) {
        return CarbonResult<void>::err(ErrorCode::ERR_HASH_IO_ERROR, "Cannot open smali file for writing");
    }
    out << content;
    out.close();

    return CarbonResult<void>::ok();
}

} // namespace carbon::security
