# 🔐 UN1CA Carbon — Cryptographic Architecture & Security

This document details the security posture, cryptographic design, and anti-detection mechanisms of **UN1CA Carbon IX**.

---

## 🏛️ Private RSA-4096 Keys vs. AOSP Public Test-Keys

A foundational architectural decision of **UN1CA Carbon IX** is our strict rejection of default public AOSP test-keys (`CN=Android`). All production packages and partitions are cryptographically signed using our dedicated **4-Tier RSA 4096-bit Keyset** issued and held exclusively by **ALRI GROUP**:

* 🔑 **Platform Key:** Signs the operating system core, `framework.jar`, and privileged managers.
* 🔑 **Release Key:** Cryptographically anchors OTA updates and system package signatures.
* 🔑 **Media Key:** Governs onboard media frameworks and audio routing engines.
* 🔑 **Shared Key:** Authenticates shared runtime data enclaves between system applications.

---

### ⚠️ The Fatal Vulnerability of AOSP Public Test-Keys
In generic custom ROMs, the default cryptographic keys (located in `build/make/target/product/security/`) are **open-source and publicly downloadable by anyone on the internet**:

1. **Total Privilege Escalation (`signature` / `signatureOrSystem`):** Android automatically grants root-level system permissions and private API access to any installed APK that shares the same signature as the operating system.
2. **Malware Ingress:** On a ROM signed with public test-keys, **any malicious application on the web compiled with that public key automatically inherits full System UID (1000) privileges**. It can silently read internal databases, intercept keystrokes, and compromise private data without triggering a single permission prompt or root request.
3. **Google Play Integrity Gating:** Modern integrity engines flag public `test-keys` as uncertified development environments, breaking banking apps, Google Wallet, and DRM streaming.

---

### 🔓 Developer Freedom: Integrated Signature Bypass Toggles
While UN1CA Carbon enforces private RSA-4096 keys by default, **we believe in absolute user freedom**. If you are a modder or developer who needs to install patched system applications, you do **not** need to flash insecure test-keys. Simply navigate to **Settings > UN1CA Carbon Settings** and enable our built-in toggles:

* **Disable Signature Verification (CorePatch):** Disables system signature checks on demand.
* **Allow Application Downgrade:** Permits installing older versions of any application without wiping data.
* **Disable Low Target SDK Block:** Enables installing legacy applications built for older Android releases.

---

## 🛡️ Play Integrity & Stealth Verification

UN1CA Carbon is engineered to provide complete stealth for banking, enterprise, and DRM services out of the box:

| Verification Suite | Target Requirement | Status / Result |
| :--- | :--- | :---: |
| **Play Integrity (Basic)** | `MEETS_BASIC_INTEGRITY` | 🟢 **PASS** |
| **Play Integrity (Device)** | `MEETS_DEVICE_INTEGRITY` | 🟢 **PASS** |
| **Play Integrity (Strong)** | `MEETS_STRONG_INTEGRITY` | 🟢 **PASS** (with recommended stack) |
| **Native Detector** | Native NDK, Zygote, & ptrace checks | 🟢 **0 Detections (100% Clean)** |
| **Duck Detector** | Ring-0 root detection evasion | 🟢 **100% Stealth** |

---

## 🔒 Knox Matrix & Account Synchronization Fix
On stock Samsung firmware running on an unlocked bootloader (`Knox 0x1`), Samsung's background daemons (`KmxService` and `fabric_crypto`) repeatedly fail hardware attestation enclaves, triggering automatic Samsung Account logouts and persistent session invalidation loops.

**UN1CA Carbon permanently mitigates this** by safely neutralizing `KmxService` and `fabric_crypto` while preserving Knox Core features needed for core UI stability.
