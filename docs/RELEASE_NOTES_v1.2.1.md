# 👑 UN1CA Carbon IX (v1.2.1) — Official Hotfix Release Notes

<div align="center">
  <img alt="UN1CA Carbon Banner" src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/banner.jpeg" width="100%">
</div>

<br>

**Target Device:** Samsung Galaxy S23 Base Universal (`SM-S911B` & `SM-S9110` / `dm1q`)  
**OS Version:** One UI 9.0 Stable (Android 17 • SDK 37)  
**Base Firmware:** `S911BXXUAGZIF` (Official Production Base)  
**Firmware Bootloader Bit:** **FIRMWARE BIT A** (Binary A / SW REV A)  
**Kernel:** GoRhanHee Linux 5.15.220 + KernelSU-Next (build 33452) + SuSFS v2.3.0 + NoMount v2.2.0  
**Recovery:** Official TWRP 3.7.1_12-0 (`dm1q`) integrated  
**Release Tag:** `IX-v1.2.1`  
**Branch:** `carbon-ix-v1.2.1`  
**Signature Profile:** `OFFICIAL_CARBON_KEYS` (RSA 4096-bit ALRI GROUP)  
**Security Patch Level:** 2026-10-05  
**Lead Architect:** Alexsander "AlexsAR" ALRI (`alexsanderalri@alrigroup.com`)  

---

## 🛡️ Kernel & Root Management
* **Integrated Kernel:** GoRhanHee Linux 5.15.220 + SuSFS v2.3.0 + NoMount v2.2.0
* **KernelSU-Next CI Channel:** 📲 [https://t.me/ksunext_ci](https://t.me/ksunext_ci)
* **Recommended Manager APK:** 📥 [KernelSU-Next CI Build #15234](https://t.me/ksunext_ci/15234)

---

## 📸 Screenshots & Verification Evidence

| Play Integrity (STRONG) | Duck Detector (Clean) | Native Detector (Clean) |
| :---: | :---: | :---: |
| <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/IX-v1.2/PIF.jpg" width="250"/> | <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/IX-v1.2/duck.jpg" width="250"/> | <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/IX-v1.2/native.jpg" width="250"/> |
| **Passes MEETS_STRONG_INTEGRITY** | **100% Anti-Detection Stealth** | **Native Root & Environment Clean** |

| UN1CA Carbon Settings | Software Information (One UI 9.0) |
| :---: | :---: |
| <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/IX-v1.2/carbonsettings.jpg" width="250"/> | <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/IX-v1.2/info.jpg" width="250"/> |
| **Custom Controls & Performance Tuning** | **Android 17 • One UI 9.0 Stable (GZIF)** |

---

## 🚀 Complete Changelog: What's New in Hotfix v1.2.1

### 1. 🎛️ SystemUI & WindowManager Null-Safety (Hotfix)
* **Resolved Control Menu Empty State & Edit Button UI Crash:** Restored null-pointer guard in `WindowManagerService` (`services.jar`) for `mPrivacyDisplayController`. If the physical privacy display controller is null (as on `dm1q`/S23 hardware), `getPrivacyDisplayCustomAppList(I)` returns an empty `ArrayList` instead of throwing `NullPointerException`, `requestPrivacyDisplayEnable` restores Binder identity safely, and `setAppPolicy` returns early.
* **Eliminated Android Rescue Party Reboot Loops:** Fixed the recurring startup bootloop where repeated SystemUI crashes triggered the system watchdog and "Serious software issue detected" panic notification.
* **Preserved Zero-Red-Dot Integrity:** Ensured Display Settings menu remains 100% free of persistent red notification badges (`SEC_FLOATING_FEATURE_LCD_CONFIG_PRIVACY_DISPLAY=0`).

### 2. 📷 Camera & Background Audio Stabilization (Hotfix)
* **Guarded AudioTask Against UnsupportedOperationException:** Wrapped `AudioRecord$Builder.build()` and state verification in `com.samsung.android.speech.AudioTask` (`framework.jar`) with a general exception handler. If background music playback (Spotify, Apple Music, YouTube Music) is active and the Qualcomm audio hardware rejects concurrent microphone capture, the camera voice-command module gracefully degrades without crashing `com.sec.android.app.camera`. When no background music is playing, voice control commands operate normally.

---

## 📲 Installation Instructions

* **Coming from v1.0 / v1.1 / v1.2:** Flash `UN1CA_Carbon_IX_1.2.1_dm1q_GZIF.zip` via TWRP or `adb sideload` (Wipe Cache/Dalvik recommended; dirty flash supported).
* **Clean Installation (Scenario A / Bit A Base):** Boot into TWRP > Wipe > Format Data (`yes`) > Flash ZIP > Reboot System.
* **For detailed Odin Bit A upgrade instructions, refer to:** **[docs/INSTALLATION.md](INSTALLATION.md)**.

---

## 📥 Official Download Links & Cryptographic Checksums

| Artifact / File | Description | Official Download Link |
| :--- | :--- | :--- |
| **`UN1CA_Carbon_IX_1.2.1_dm1q_GZIF.zip`** | Full Signed Flashable Package (8.17 GB) | 🔗 **[Direct Google Drive ZIP](https://drive.google.com/file/d/1uz2626y9vmr4lhf3B3-ja9JbFrRYWu69/view?usp=drive_link)** |
| **`UN1CA_Carbon_IX_1.2.1_dm1q_GZIF.zip.sha256`** | Official Cryptographic Checksum Record | 🔐 **[Download Checksum](https://drive.google.com/file/d/17FKq0BeDl14cg3mqCJlLHbf8KIqaCYRi/view?usp=drive_link)** |
| **`build_manifest.json`** | Enterprise v2 Cryptographic Manifest (SLSA/SBOM) | 📄 **[Download Manifest](https://drive.google.com/file/d/1-JALqcI3iiUQVqLEdDrgChesqdcfhvx5/view?usp=drive_link)** |
| **`build_forensic_audit.log`** | Human-Readable Forensic Audit Report | 📋 **[Download Audit Log](https://drive.google.com/file/d/1zvbfVKi9p4Ppc1ap83I0oOqPk7JhmGsJ/view?usp=drive_link)** |
| **`build_engine.log`** | Carbon Engine C++20 Full Execution Log | 📜 **[Download Build Log](https://drive.google.com/file/d/1IPwI0OHhI2HifWGz-hWp8flmhtXz1agb/view?usp=drive_link)** |
| **Complete Google Drive Folder** | All artifacts, logs, and checksums in one directory | 📂 **[Access Google Drive Folder](https://drive.google.com/drive/folders/1lWvasfMYxzV-fEZ3UvhUvL9PKS4u7G5J?usp=drive_link)** |

* **Package Checksum SHA-256:** `6c5298303896cccb3eabf9676d67fb8bbed584703d9ae4dfb774ca0b8c45ead3`
* **Composite Build Fingerprint:** `c509ad61707e5b2efa0bbdbd7f783a33bad5108b06aeed0e5596688969df4a7a`
* **Official Google Drive Release Directory:**  
  👉 **[https://drive.google.com/drive/folders/1lWvasfMYxzV-fEZ3UvhUvL9PKS4u7G5J?usp=drive_link](https://drive.google.com/drive/folders/1lWvasfMYxzV-fEZ3UvhUvL9PKS4u7G5J?usp=drive_link)**
