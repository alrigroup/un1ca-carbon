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
| **`UN1CA_Carbon_IX_1.2_dm1q_GZIF.zip`** | Full Signed Flashable Package (8.2 GB) | 📂 **[Download via Google Drive Release Folder](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)** |
| **`UN1CA_Carbon_IX_1.2_dm1q_GZIF.zip.sha256`** | Official Cryptographic Checksum Record | 📂 **[Download via Google Drive Release Folder](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)** |
| **`build_manifest.json`** | Enterprise v2 Cryptographic Manifest (SLSA/SBOM) | 📂 **[Download via Google Drive Release Folder](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)** |
| **`build_forensic_audit.log`** | Human-Readable Forensic Audit Report | 📂 **[Download via Google Drive Release Folder](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)** |
| **`build_engine.log`** | Carbon Engine C++20 Full Execution Log | 📂 **[Download via Google Drive Release Folder](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)** |

* **Official Google Drive Release Directory:**  
  👉 **[https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing](https://drive.google.com/drive/folders/1tIanbf9x7SMK8xiY1DWQx99YI6BtCpRW?usp=sharing)**

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

## 📲 Installation Instructions

* **Coming from v1.0 / v1.1:** Flash `UN1CA_Carbon_IX_1.2_dm1q_GZIF.zip` via TWRP or `adb sideload` (Wipe Cache/Dalvik recommended; dirty flash supported).
* **Clean Installation (Scenario A / Bit A Base):** Boot into TWRP > Wipe > Format Data (`yes`) > Flash ZIP > Reboot System.
* **For detailed Odin Bit A upgrade instructions, refer to:** **[docs/INSTALLATION.md](INSTALLATION.md)**.
