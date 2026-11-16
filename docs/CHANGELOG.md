# 📜 UN1CA Carbon — Changelog & Version History

This document catalogs the complete technical changelog and historical evolution of **UN1CA Carbon IX** across releases.

---

## 🚀 UN1CA Carbon IX v1.2.1 (Official Hotfix Release)
**Target Base:** `S911BXXUAGZIF` (Official Samsung Production Base • Firmware Bit A)  
**Security Patch:** 2026-10-05 • Android 17 (One UI 9.0 Stable • SDK 37)  
**Branch:** `carbon-ix-v1.2.1`  
**Lead Architect:** Alexsander "AlexsAR" ALRI (`alexsanderalri@alrigroup.com`)

### 1. 🎛️ SystemUI & WindowManager Null-Safety (Hotfix)
* **Resolved Control Menu Empty State & Edit Button UI Crash:** Restored null-pointer guard in `WindowManagerService` (`services.jar`) for `mPrivacyDisplayController`. If the physical privacy display controller is null (as on `dm1q`/S23 hardware), `getPrivacyDisplayCustomAppList(I)` returns an empty `ArrayList` instead of throwing `NullPointerException`, `requestPrivacyDisplayEnable` restores Binder identity safely, and `setAppPolicy` returns early.
* **Eliminated Android Rescue Party Reboot Loops:** Fixed the recurring startup bootloop where repeated SystemUI crashes triggered the system watchdog and "Serious software issue detected" panic notification.
* **Preserved Zero-Red-Dot Integrity:** Ensured Display Settings menu remains 100% free of persistent red notification badges (`SEC_FLOATING_FEATURE_LCD_CONFIG_PRIVACY_DISPLAY=0`).

### 2. 📷 Camera & Background Audio Stabilization (Hotfix)
* **Guarded AudioTask Against UnsupportedOperationException:** Wrapped `AudioRecord$Builder.build()` and state verification in `com.samsung.android.speech.AudioTask` (`framework.jar`) with a general exception handler. If background music playback (Spotify, Apple Music, YouTube Music) is active and the Qualcomm audio hardware rejects concurrent microphone capture, the camera voice-command module gracefully degrades without crashing `com.sec.android.app.camera`. When no background music is playing, voice control commands operate normally.

---

## 🚀 UN1CA Carbon IX v1.2 (Official Production Release)
**Target Base:** `S911BXXUAGZIF` (Official Samsung Production Base • Firmware Bit A)  
**Security Patch:** 2026-10-05 • Android 17 (One UI 9.0 Stable • SDK 37)  
**Branch:** `dev-carbon-ix-v1.2` (Target Milestone v1.2)  
**Lead Architect:** Alexsander "AlexsAR" ALRI (`alexsanderalri@alrigroup.com`)

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
* **Health Connect APEX Verification:** Validated `com.android.healthfitness` controller resolution (`PermissionsActivity`), resolving upstream `ActivityNotFoundException` errors.

### 5. 🐧 Kernel, Performance & Scheduler
* **GoRhanHee Kernel Upstream v2026.11.02 (#13, #15):** Upstreamed Linux kernel to **5.15.220** for Snapdragon 8 Gen 2 (`sm8550`/`kalama`), updated KernelSU-Next driver to build 33452, updated SuSFS to v2.3.0, integrated NoMount v2.2.0 driver, and synchronized ramdisk modules and `vendor_dlkm`/`system_dlkm` partition images.
* **WALT Scheduler & 120Hz Frame Pacing (#15):** Verified Qualcomm WALT governor topology, delivering 5ms median UI rendering latency on Skia Vulkan.
* **Audio HAL Stability (#14):** Stabilized audio routing configurations and mixer paths across stereo drivers.

### 6. 🌐 Hardware Variant Support (SM-S9110)
* **Early-Init RIL Dual-SIM Trigger:** Advanced `unica_hardware_variant.rc` triggers to `on early-init`, guaranteeing the Qualcomm QCRIL daemon initializes in Dual-SIM Dual-Standby (DSDS) mode at the earliest boot stage for Hong Kong, Taiwan, and China hardware.

---

## 🏛️ UN1CA Carbon IX v1.1 (Previous Milestone)
**Target Base:** `S911BXXUAGZIF` (Official Samsung Production Base • Firmware Bit A)  
**Security Patch:** 2026-10-05 • Android 17 (One UI 9.0 Stable • SDK 37)  
**Release Notes:** [docs/RELEASE_NOTES_v1.1.md](RELEASE_NOTES_v1.1.md)

### 1. 🌐 Base Firmware & Multi-Variant Hardware
* **Official Stable Firmware Promotion:** Promoted from One UI 9 beta `ZZI8` to the official Samsung production base **`S911BXXUAGZIF`** (Firmware Bit A / SW REV A).
* **Universal Galaxy S23 Base Support:** Unified installer package compatible with both European/Global **`SM-S911B`** and Chinese/Hong Kong/Taiwanese **`SM-S9110`** models.
* **Dynamic SIM Hardware Adaptation:** Integrated runtime hardware initialization (`unica_hardware_variant.rc`) automatically enabling Dual Physical SIM (`dsds`) on S9110 devices while preserving eSIM capabilities on S911B hardware.

### 2. 🔐 Security, Cryptography & Enterprise Signing
* **Official ALRI GROUP RSA-4096 Keyset:** Completely decoupled from AOSP public test-keys (`CN=Android`). All production artifacts and system partitions are now cryptographically signed using our 4-tier dedicated RSA 4096-bit keyset (`platform`, `releasekey`, `media`, `shared`).
* **Hardware-Level Signature Masking:** Custom framework hooks in `services.jar` allowing system-privileged applications to execute without signature mismatch rejections while protecting setup-wizard integrity.
* **Knox Matrix & Session Desynchronization Fix:** Permanently purged Samsung's `KmxService` and `fabric_crypto` background daemons, stopping Samsung Account automatic logout and session invalidation loops on unlocked bootloaders (Knox 0x1).

### 3. 🎛️ Carbon Performance Engine & Hardware Tuning
* **Native One UI Performance Dropdown:** Built directly into the primary `SecSettings.apk` dashboard:
  * 🍃 **Light Mode:** Clamps Prime Cortex-X3 to 1.97 GHz and Adreno 740 GPU to 348 MHz for maximum battery preservation and ice-cold thermals.
  * ⚖️ **Normal Mode:** Factory stock Snapdragon 8 Gen 2 for Galaxy frequencies.
  * 🔥 **Performance Mode:** Eliminates governor ramp-up latency (`up_rate_limit_us=0`), enables aggressive Adreno 740 clock floors, and boosts UFS read-ahead I/O to 512 KB.
* **8 GB ZRAM with Native ZSTD Compression:** Upgraded swap subsystem from legacy `lzo-rle` to high-speed **ZSTD** compression with `swappiness=100`, eliminating background application reloads.
* **Advanced GPU Tuning (Adreno 740):** Integrated KonaBess C++ native worker (`/system/bin/unica-gpu`) with live settings interface, automatic TWRP rollback safety partition, and dynamic FDT/DTB voltage curve adaptation.

### 4. 🧠 Local AI & Neural Framework (Qwen 2.5 LLM)
* **On-Device Offline Intelligence:** Integrated Qwen 2.5 1.5B/7B GGUF model framework running via `librezoss_llama` engine service (`io.mesalabs.rezoss.qwen`).
* **Settings Management Dashboard:** Dedicated Settings menu with real-time model status, hardware acceleration metrics (Snapdragon 8 Gen 2 Hexagon NPU + Adreno 740), and direct model download trigger.
* **Galaxy AI Writing Toolkit & SmartReply:** Enabled Samsung Keyboard (`HoneyBoard`) writing assistant capabilities, conversational tone adjustments, and Smart Suggestions for WhatsApp, Telegram, and Samsung Messages.

### 5. 📞 Audio Subsystem & Call Screening
* **Bixby Text Call Telephony Routing:** Resolved Qualcomm audio policy routing blocks by authorizing `AUDIO_CHANNEL_OUT_MONO` and 32 kHz sampling rates on `incall_music_uplink` and `voice_tx`.
* **Qualcomm PAL Graph Integration:** Injected `PAL_STREAM_VOICE_CALL_MUSIC` with `icmd_plus` custom config into `usecaseKvManager.xml`.
* **Audio Eraser & SoundAlive 2025:** Added neural voice/noise separation engines (`libmultisourceseparator.so`) and updated Galaxy 2025 acoustic audio profile.
* **SmartView & Wireless DeX HDCP Bypass:** Permanent bypass (`wlan.wfd.hdcp=disable`) enabling wireless screen projection to Smart TVs and PCs.

### 6. 🛠️ Build Engine & Pipeline Infrastructure
* **Carbon Engine C++20:** Replaced monolithic bash build scripts with a native C++20 build orchestrator featuring input-addressed DAG caching.
* **Cryptographic Forensic Manifest:** Every build now generates `out/build_manifest.json` cataloging deep SHA-256 hashes of every module, component, and recompiled APK/JAR.
* **Build Date Precision:** Fixed the legacy NPL "Unknown" build date bug in Settings by reading authentic system build timestamps (`ro.build.date`).

---

## 🏛️ UN1CA Carbon IX v1.0 (Initial Public Milestone)
**Target Base:** `S911BXXUAZZI8` (Initial Beta Base • Firmware Bit A)  
**Release Notes:** [docs/RELEASE_NOTES_v1.0.md](RELEASE_NOTES_v1.0.md)

* Initial One UI 9.0 (Android 17 • SDK 37) base port engineered for Galaxy S23 Base (`SM-S911B` / `dm1q`).
* Fixed Qualcomm SurfaceFlinger display compositor crashes (`fmt::v12` linker binding).
* Implemented 120Hz zero-flickering adaptive refresh rate calibration (`HFR Mode 2`).
* Preserved authentic Samsung Hardware FBE v2 encryption without DFE hacks.
* Integrated GoRhanHee Linux 5.15.216 kernel with KernelSU-Next v3.4.2 and SUSFS.
* Pre-packaged official TWRP 3.7.1 recovery in a single-flash installer zip.
* Added native Call Recording (`ril.call.recording=true`) and telemetry debloating.
