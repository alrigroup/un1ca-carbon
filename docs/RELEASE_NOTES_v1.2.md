# 👑 UN1CA Carbon IX (v1.2) — Official Release Notes

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
**Release Tag:** `IX-v1.2`  
**Git Source Commit:** `8e2b246` (CLEAN • Official Release)  
**Signature Profile:** `OFFICIAL_CARBON_KEYS` (RSA 4096-bit ALRI GROUP)  
**Security Patch Level:** 2026-10-05  
**Lead Architect:** Alexsander "AlexsAR" ALRI (`alexsanderalri@alrigroup.com`)  

---

## 📥 Official Download Links & Cryptographic Checksums

| Artifact / File | Description | Official Download Link |
| :--- | :--- | :--- |
| **`UN1CA_Carbon_IX_1.2_dm1q_GZIF.zip`** | Full Signed Flashable Package (8.17 GB) | 📂 **[Download via Google Drive Release Folder](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)** |
| **`UN1CA_Carbon_IX_1.2_dm1q_GZIF.zip.sha256`** | Official Cryptographic Checksum Record | 📂 **[Download via Google Drive Release Folder](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)** |
| **`build_manifest.json`** | Enterprise v2 Cryptographic Manifest (SLSA/SBOM) | 📂 **[Download via Google Drive Release Folder](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)** |
| **`build_forensic_audit.log`** | Human-Readable Forensic Audit Report | 📂 **[Download via Google Drive Release Folder](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)** |
| **`build_engine.log`** | Carbon Engine C++20 Full Execution Log | 📂 **[Download via Google Drive Release Folder](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)** |
| **Complete Google Drive Folder** | All artifacts, logs, and checksums in one directory | 📂 **[Access Google Drive Folder](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)** |

* **Package Checksum SHA-256:** `4044a3e208d5f51c47e14690394d9915ad86c6b861ece21b3131e37db5682a0f`
* **Composite Build Fingerprint:** `96f80451112dc2c7df50615b6043e4ec847416f58f6e89368a7e35e225c95117`
* **Official Google Drive Release Directory:**  
  👉 **[https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)**

---

## 🛡️ Kernel & Root Management
* **Integrated Kernel:** GoRhanHee Linux 5.15.220 + SuSFS v2.3.0 + NoMount v2.2.0
* **KernelSU-Next CI Channel:** 📲 [https://t.me/ksunext_ci](https://t.me/ksunext_ci)
* **Recommended Manager APK:** 📥 [KernelSU-Next CI Build #15234](https://t.me/ksunext_ci/15234)

---

## 📸 Screenshots & Verification Evidence

| Play Integrity (STRONG) | Duck Detector (Clean) | Native Detector (Clean) |
| :---: | :---: | :---: |
| <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/PIF.jpg" width="250"/> | <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/duck.jpg" width="250"/> | <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/native.jpg" width="250"/> |
| **Passes MEETS_STRONG_INTEGRITY** | **100% Anti-Detection Stealth** | **Native Root & Environment Clean** |

| UN1CA Carbon Settings | Software Information (One UI 9.0) |
| :---: | :---: |
| <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/carbonsettings.jpg" width="250"/> | <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/info.jpg" width="250"/> |
| **Custom Controls & Performance Tuning** | **Android 17 • One UI 9.0 Stable (GZIF)** |

---

## 🚀 Complete Changelog: What's New from v1.1 to v1.2

### 1. 🎛️ User Interface, Display & Aesthetics
* **Display Red Dot Badge Removal (#2, #5):** Purged unsupported Privacy Display emulation overlays from SecSettings, SystemUI, and services.jar. Enforced `SEC_FLOATING_FEATURE_LCD_CONFIG_PRIVACY_DISPLAY=0`, permanently extinguishing the unremovable red notification badge on the Display Settings menu.
* **Power Menu Circular Icons (#8):** Standardized Advanced Power Menu actions (Reboot to Recovery and Flight Mode) with native 60dp circular background framing (`sec_globalactions_icon_airplane` and `sec_globalactions_icon_recovery`), resolving visual size and contrast mismatches.
* **Stock Galaxy S23 Wallpapers (#9):** Restored the 4 authentic high-resolution Galaxy S23 (`dm1q`) stock wallpapers (Botanic Green, Cotton Flower, Misty Lilac, Phantom Black) to the picker catalog and featured row alongside Carbon and Sagarmatha collections.
* **Samsung Boot Animation (#6):** Added authentic Samsung One UI animated shining wordmark and pulse loop (`bootanimation_samsung.zip` at 1080x2340 30fps) as a third selectable option in Carbon Settings alongside UN1CA Carbon and Android 17 AOSP, with authentic dropdown branding.
* **Enhanced 120Hz Animation Physics (0.85x Multiplier):** Fine-tuned system default window, transition, and animator duration scales to `0.85x` in `WindowManagerService` and `SettingsProvider`, delivering instant touch responsiveness while preserving smooth One UI physics.

### 2. 📷 Camera & Media Subsystem
* **4K 120 FPS Recording (#3):** Unlocked `BACK_CAMCORDER_RESOLUTION_FEATURE_MAP_3840X2160_120FPS` for Pro Video and Slow Motion modes on the Snapdragon 8 Gen 2 platform.
* **Continuous Background Audio (#3):** Enabled `CscFeature_Camera_CamcorderDoNotPauseMusic = TRUE`, allowing video recording without interrupting music playback from Spotify, Apple Music, or YouTube Music.
* **Superfine JPEG Quality (#3):** Set `CscFeature_Camera_DefaultQuality = superfine` to minimize lossy compression artifacts.
* **In-Call Camera Activation (#3):** Set `CscFeature_Camera_EnableCameraDuringCall = TRUE`.
* **HDR Tone Mapping & Auto-Gain Stabilization (#12):** Aligned 60FPS camcorder modes on the ISOCELL S5KGN3 sensor to standard 8-bit multi-frame HDR (`hdr10="false"` at 60fps), eliminating the Qualcomm Spectra ISP PQ curve tone mapping collapse and stopping the abnormal ISO 6400 ceiling lock.
* **Preserved Native Video Toggles:** Maintained official LOG Video and HDR/HLG dynamic range selectors with dedicated UI switches.

### 3. 🔋 Battery, Power & Standby Efficiency
* **IMS Alarm Loop Mitigation (#11):** Throttled unprovisioned European carrier switch loops via `persist.radio.imsserviceswitch=false`, `ro.telephony.ims.alarm_throttle=true`, and framework CSC hook `CscFeature_IMS_EnableAutoRetry = FALSE`, eliminating 200+ recurring wake alarms per hour that previously drained ~525 mAh in standby.
* **Sensor Hub Polling Freeze (#11):** Revoked `ACTIVITY_RECOGNITION` and `BODY_SENSORS` permissions from `SamsungDeviceHealthManagerService` (`sdhms`), halting continuous background sensor polling during sleep while preserving charging speed regulation.
* **Deep Sleep Verified:** Validated idle standby consumption rate of 0.5%–0.8% per hour.

### 4. 🧠 Intelligence, AI & Mainline Subsystems
* **Native Multilingual Now Nudge Engine (10 Languages):** Built offline contextual intelligence pipeline into `SamsungSmartSuggestions.apk` (`classes15.dex` via `NowNudgeConversationBridge`), completely eliminating heavy local LLM crashes while delivering instant reply pills across WhatsApp, Telegram, and SMS in **10 global languages** (English, Portuguese PT-BR, Spanish, Mandarin Chinese, German, Italian, Japanese, French, Korean, Indonesian) covering 214 semantic categories.
* **First-Boot Automatic Activation:** Configured `now_nudge_defaults.sh` and system database defaults (`now_nudge_enabled=1`, `nowbrief_enabled=1`, `smart_suggestions_enabled=1`) to initialize Now Nudge out of the box with zero user configuration required, alongside automatic `writing_assistant` injection for all active keyboard languages.
* **Always On Display Galaxy Store Fix (#1):** Bumped `AODService_v80` `versionCode` to `999999999` and `versionName` to `9.9.99` in `apktool.yml` and `AndroidManifest.xml`. Validated against Samsung VAS API to return `resultCode=1` (Not necessary to update), eliminating update prompts and `INSTALL_FAILED_UPDATE_INCOMPATIBLE` signature mismatch errors.
* **Google Play System Update Persistence (#10):** Prevented `deknox` from overwriting `/system/bin/apexd` and `gsid` with legacy Android 36 binaries on `dm*q` devices, ensuring authentic Android 17 APEX staging and mount persistence across reboots.
* **Samsung Now Brief / Moments (#4):** Integrated `Moments.apk`, permissions, and sysconfig from `pa2qxxx`, activating `SEC_FLOATING_FEATURE_COMMON_CONFIG_AI_VERSION = 20263`, `SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_NOW_BRIEF = TRUE`, and `SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_PERSONALIZED_DATA_CORE = TRUE`.
* **AI Semantic Search in Settings (#7):** Integrated `MediaSearch.apk`, `SemanticSearchCore.apk`, 400-dimension neural embeddings in `SecSettingsIntelligence.apk`, and enabled `SEC_FLOATING_FEATURE_MSCH_SUPPORT_NLSEARCH = TRUE`.

### 5. 🐧 Kernel, Performance & Scheduler
* **GoRhanHee Kernel Upstream v2026.11.02 (#13, #15):** Upstreamed Linux kernel to **5.15.220** for Snapdragon 8 Gen 2 (`sm8550`/`kalama`), updated KernelSU-Next driver to build 33452, updated SuSFS to v2.3.0, integrated NoMount v2.2.0 driver, and synchronized ramdisk modules and `vendor_dlkm`/`system_dlkm` partition images.
* **WALT Scheduler & 120Hz Frame Pacing (#15):** Verified Qualcomm WALT governor topology, delivering 5ms median UI rendering latency on Skia Vulkan.
* **Audio HAL Stability (#14):** Stabilized audio routing configurations and mixer paths across stereo drivers.

### 6. 🌐 Hardware Variant Support (SM-S9110)
* **Early-Init RIL Dual-SIM Trigger:** Advanced `unica_hardware_variant.rc` triggers to `on early-init`, guaranteeing the Qualcomm QCRIL daemon initializes in Dual-SIM Dual-Standby (DSDS) mode at the earliest boot stage for Hong Kong, Taiwan, and China hardware.

---

## 🔗 Git Commit Lineage & Engineering Traceability

| Component / Issue | Description | Originating Commit |
| :--- | :--- | :---: |
| **Now Nudge Multilingual** | 10 global languages (EN, PT, ES, ZH, DE, IT, JA, FR, KO, ID) & auto boot defaults | [`a233bcc`](https://github.com/alrigroup/un1ca-carbon/commit/a233bcc) |
| **Now Nudge Continuous Pipeline** | Complete `0016-0027` Smali patches & WhatsApp chat bridge | [`ef3da57`](https://github.com/alrigroup/un1ca-carbon/commit/ef3da57) |
| **Carbon Engine C++20 Alignment** | 100% DAG pipeline synchronization & OpenSSL 3.4 API cast | [`c6c942b`](https://github.com/alrigroup/un1ca-carbon/commit/c6c942b) |
| **Issue #1 (AOD)** | Bump AODService versionCode to 999999999 (Fix Galaxy Store) | [`c066d16`](https://github.com/alrigroup/un1ca-carbon/commit/c066d16) |
| **Issue #2 & #5 (Display)** | Purge Privacy Display emulation and extinguish red dot badge | [`9a23964`](https://github.com/alrigroup/un1ca-carbon/commit/9a23964) |
| **Issue #3 (Camera)** | 4K 120 FPS Pro Video, continuous music recording & superfine JPEG | [`78fa9f6`](https://github.com/alrigroup/un1ca-carbon/commit/78fa9f6) |
| **Issue #4 (Now Brief)** | Samsung Now Brief / Moments integration & LLM version 1.70 | [`29e5096`](https://github.com/alrigroup/un1ca-carbon/commit/29e5096) |
| **Issue #6 (Boot Animation)** | Authentic "Samsung Boot Animation" selector in Carbon Settings | [`7aff32a`](https://github.com/alrigroup/un1ca-carbon/commit/7aff32a) |
| **Issue #7 (Semantic Search)** | AI Semantic Search in Settings via neural embeddings | [`308cdc2`](https://github.com/alrigroup/un1ca-carbon/commit/308cdc2) |
| **Issue #8 (Power Menu)** | Standardized 60dp circular icons for Recovery and Flight Mode | [`6a764bc`](https://github.com/alrigroup/un1ca-carbon/commit/6a764bc) |
| **Issue #9 (Wallpapers)** | Restored authentic Galaxy S23 high-res stock wallpapers | [`71bd1c8`](https://github.com/alrigroup/un1ca-carbon/commit/71bd1c8) |
| **Issue #10 (Mainline)** | Preserve native S23 apexd and gsid to prevent Play System rollbacks | [`6f6c1e9`](https://github.com/alrigroup/un1ca-carbon/commit/6f6c1e9) |
| **Issue #11 (Battery)** | Mitigate IMS alarm loops and sensor hub wakelocks | [`42d1cb1`](https://github.com/alrigroup/un1ca-carbon/commit/42d1cb1) |
| **Issue #12 (Camera HDR/LOG)**| Stabilize 60FPS HDR tone mapping and preserve LOG Video switches | [`908b4b7`](https://github.com/alrigroup/un1ca-carbon/commit/908b4b7) |
| **Issue #13 & #15 (Kernel)** | GoRhanHee Kernel v2026.11.02 (Linux 5.15.220 + SuSFS 2.3.0 + NoMount) | [`ba4dbc8`](https://github.com/alrigroup/un1ca-carbon/commit/ba4dbc8) |
| **Issue #14 (Audio HAL)** | SoundAlive 2025 acoustic profile & PAL graph audio routing | [`05c72a0`](https://github.com/alrigroup/un1ca-carbon/commit/05c72a0) |

---

## 📲 Installation Instructions

* **Coming from v1.0 / v1.1:** Flash `UN1CA_Carbon_IX_1.2_dm1q_GZIF.zip` via TWRP or `adb sideload` (Wipe Cache/Dalvik recommended; dirty flash supported).
* **Clean Installation (Scenario A / Bit A Base):** Boot into TWRP > Wipe > Format Data (`yes`) > Flash ZIP > Reboot System.
* **For detailed Odin Bit A upgrade instructions, refer to:** **[docs/INSTALLATION.md](INSTALLATION.md)**.
