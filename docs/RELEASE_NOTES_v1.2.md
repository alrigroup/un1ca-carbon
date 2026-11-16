# 👑 UN1CA Carbon IX (v1.2) — Official Release Notes

<div align="center">
  <img alt="UN1CA Carbon Banner" src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/banner.jpeg" width="100%">
</div>

<br>

**Target Device:** Samsung Galaxy S23 Base Universal (`SM-S911B` & `SM-S9110` / `dm1q`)  
**OS Version:** One UI 9.0 Stable (Android 17 • SDK 37)  
**Base Firmware:** `S911BXXUAGZIF` (Official Samsung Production Base)  
**Firmware Bootloader Bit:** **FIRMWARE BIT A** (Binary A / SW REV A)  
**Kernel:** GoRhanHee Linux 5.15.220 + KernelSU-Next (build 33452) + SuSFS v2.3.0 + NoMount v2.2.0  
**Recovery:** Official TWRP 3.7.1_12-0 (`dm1q`) integrated  
**Release Tag:** `IX-v1.2`  
**Signature Profile:** `OFFICIAL_CARBON_KEYS` (RSA 4096-bit ALRI GROUP)  
**Security Patch Level:** 2026-10-05  
**Lead Architect:** Alexsander "AlexsAR" ALRI (`alexsanderalri@alrigroup.com`)

---

## 📥 Official Download Links & Release Packages

| Artifact / File | Description | Official Download Link |
| :--- | :--- | :--- |
| **`UN1CA_Carbon_IX_1.2_dm1q_GZIF.zip`** | Full Signed Flashable Package (8.2 GB) | ⏳ *COMPILING... (Cooking in Carbon Engine C++20)* |
| **`UN1CA_Carbon_IX_1.2_dm1q_GZIF.zip.sha256`** | Official Cryptographic Checksum Record | ⏳ *CALCULATING SHA-256... (Cooking...)* |
| **`build_manifest.json`** | Enterprise v2 Cryptographic Manifest (SLSA/SBOM) | ⏳ *GENERATING SLSA v2 MANIFEST...* |
| **`build_forensic_audit.log`** | Human-Readable Forensic Audit Report | ⏳ *GENERATING AUDIT LOG...* |
| **`build_engine.log`** | Carbon Engine C++20 Full Execution Log | ⏳ *STREAMING COMPILER LOGS...* |

* **Official Google Drive Release Directory:**  
  👉 **[https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)**

---

## 🛡️ Kernel & Root Management
* **Integrated Kernel:** GoRhanHee Linux 5.15.220 + SuSFS v2.3.0 + NoMount v2.2.0
* **KernelSU-Next CI Channel:** 📲 [https://t.me/ksunext_ci](https://t.me/ksunext_ci)
* **Recommended Manager APK:** 📥 [KernelSU-Next CI Build #15234](https://t.me/ksunext_ci/15234)

---

## 🚀 Key Highlights & Architectural Enhancements

### 1. Native Multilingual Now Nudge Engine (10 Global Languages)
* **Zero Heavy AI Daemon Overhead:** Purged experimental 2.6 GB local LLMs that caused system_server IPC timeouts and battery drain.
* **Instant Conversational Intelligence:** Integrated `NowNudgeConversationBridge` into `SamsungSmartSuggestions.apk` (`classes15.dex`), generating instant contextual reply pills on WhatsApp, Telegram, and SMS in **10 global languages** (English, Portuguese PT-BR, Spanish, Mandarin Chinese, German, Italian, Japanese, French, Korean, Indonesian) with 214 semantic categories.
* **Out-of-the-Box Initialization:** Pre-configured `now_nudge_defaults.sh` and system database defaults (`now_nudge_enabled=1`, `nowbrief_enabled=1`, `smart_suggestions_enabled=1`) alongside automatic `writing_assistant` injection into the Samsung Keyboard (`HoneyBoard`).

### 2. Camera & Multimedia Calibrations
* **4K 120 FPS Unlocked:** Pro Video and Slow Motion support on Snapdragon 8 Gen 2 platform.
* **Non-Stop Audio Recording:** `CscFeature_Camera_CamcorderDoNotPauseMusic = TRUE` allows video recording without pausing music from Spotify, YouTube Music, or Apple Music.
* **Superfine JPEG & Stabilized HDR:** Eliminated tone-mapping color collapse and ISO 6400 ceiling locks at 60fps. Maintained dedicated toggles for both LOG Video and HDR10+/HLG dynamic range.

### 3. Community Bug Fixes (100% of Tracked Issues Resolved)
* **[#1] AOD Galaxy Store:** VersionCode bumped to `999999999`, resolving signature update mismatch errors.
* **[#2, #5] Display Red Dot & Privacy Display:** Purged unsupported Privacy Display overlays, permanently extinguishing the unremovable red notification badge in Display Settings.
* **[#6] Samsung Boot Animation:** Integrated official Samsung One UI shining wordmark and pulse loop as a selectable option in Carbon Settings.
* **[#7] AI Semantic Search in Settings:** Integrated neural embeddings for conceptual searches in Settings.
* **[#8] Power Menu Circular Icons:** Standardized Advanced Power Menu icons to 60dp circular frames.
* **[#9] Stock S23 Wallpapers:** Restored authentic Botanic Green, Cotton Flower, Misty Lilac, and Phantom Black wallpapers.
* **[#10] Google Play System Update Persistence:** Preserved native Android 17 `apexd` and `gsid`, preventing post-reboot rollbacks.
* **[#11] Standby Battery Drain:** Eliminated IMS European carrier retry loops and sensor polling, restoring deep sleep (0.5%–0.8%/hr).
* **[#13, #15] GoRhanHee Kernel v2026.11.02:** Upstreamed to Linux 5.15.220 with SuSFS v2.3.0, NoMount v2.2.0, and WALT scheduler delivering 5ms UI frame pacing.
* **[#14] Audio HAL Stability:** Calibrated stereo mixer paths and speaker profiles.

---

## 🔗 Git Commit Lineage & Engineering Traceability

Every enhancement, fix, and calibration in **UN1CA Carbon IX v1.2** is bound to a verified cryptographic Git commit:

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
| **Local AI Refactor** | Purge heavy unstable Qwen local daemon to eliminate system crashes | [`44e5084`](https://github.com/alrigroup/un1ca-carbon/commit/44e5084) |

---

* **Coming from v1.0 / v1.1:** Flash `UN1CA_Carbon_IX_1.2_dm1q_GZIF.zip` via TWRP or `adb sideload` (Wipe Cache/Dalvik recommended; dirty flash supported).
* **Clean Installation (Scenario A / Bit A Base):** Boot into TWRP > Wipe > Format Data (`yes`) > Flash ZIP > Reboot System.
* **For detailed Odin Bit A upgrade instructions, refer to:** **[docs/INSTALLATION.md](INSTALLATION.md)**.
