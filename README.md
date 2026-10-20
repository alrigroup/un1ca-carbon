# 👑 UN1CA Carbon

<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/logo_white.png">
  <source media="(prefers-color-scheme: light)" srcset="docs/assets/logo_dark.png">
  <img alt="UN1CA Carbon" src="docs/assets/logo_white.png" width="480">
</picture>

<br><br>

**Next-Generation One UI 9 Custom ROM for Samsung Galaxy S23 Series**  
*Release Version: **IX** (One UI 9.0 • Android 17 • SDK 37)*  
*Engineered, Ported & Stabilized for Galaxy S23 Base (`SM-S911B` / `dm1q`)*

---

[![Android](https://img.shields.io/badge/Android-17-green.svg)](https://developer.android.com)
[![OneUI](https://img.shields.io/badge/OneUI-9.0--Beta2-blue.svg)](https://www.samsung.com)
[![Device](https://img.shields.io/badge/Target-Galaxy%20S23%20(dm1q)-orange.svg)](https://github.com/alrigroup/un1ca-carbon)
[![Firmware](https://img.shields.io/badge/Firmware-Bit%20A%20(U10%2FSA)-yellow.svg)](https://github.com/alrigroup/un1ca-carbon)
[![Kernel](https://img.shields.io/badge/Kernel-GoRhanHee%205.15.216-red.svg)](https://github.com/alrigroup/un1ca-carbon)
[![Root](https://img.shields.io/badge/Root-KernelSU--Next-blueviolet.svg)](https://github.com/alrigroup/un1ca-carbon)
[![Play Integrity](https://img.shields.io/badge/Play%20Integrity-Strong%20Passed-success.svg)](https://github.com/alrigroup/un1ca-carbon)
[![Native Detector](https://img.shields.io/badge/Native%20Detector-0%20Detections-brightgreen.svg)](https://github.com/alrigroup/un1ca-carbon)
[![License](https://img.shields.io/badge/License-ARGLP-brightgreen.svg)](LICENSE)

</div>

---

## 📖 About the Project

**UN1CA Carbon** is a customized and stabilized distribution of **Samsung One UI 9.0 (Android 17 / SDK 37)** designed specifically to bring Samsung's latest software generation to the **Galaxy S23 Base (`SM-S911B` / `dm1q`)**.

While initial upstream One UI 9 experimental ports were built exclusively for the Galaxy S23 Ultra (`dm3q`), **UN1CA Carbon** bridges the architectural divide for the base S23 model:
- Resolves Qualcomm display compositor (SurfaceFlinger) crashes caused by upstream toolchain symbol mismatches;
- Fixes SystemUI media and dynamic wallpaper linkage aborts;
- Calibrates 120Hz adaptive refresh rate for the native 1080x2340 FHD+ AMOLED panel (`HFR Mode 2`, zero flickering);
- Restores official Samsung-signed input method components to guarantee out-of-the-box keyboard input across FRP-locked initial setup wizards;
- Directly integrates the **GoRhanHee Custom Kernel (Linux 5.15.216)** with **KernelSU-Next v3.4.2** and **SUSFS**;
- Preserves and automates the flashing of official **TWRP Recovery** in a single seamless installation package;
- Features the exclusive **UN1CA Carbon Boot Animation** and **Featured Wallpaper Suite**;
- Implements a configurable **Telemetry Debloater** (`DEBLOAT_TELEMETRY=true`) stripping OEM tracking daemons.

---

## 🛡️ Out-of-the-Box Security & Integrity

UN1CA Carbon comes pre-configured with kernel-level stealth and system-level attestation patches:
- **Google Play Integrity (PIF):** Passes all 3 verification tiers out-of-the-box (`MEETS_BASIC_INTEGRITY`, `MEETS_DEVICE_INTEGRITY`, and `MEETS_STRONG_INTEGRITY`).
- **Native Detector:** **0 Detections** — clean system environment across security benchmarks.
- **Stealth Architecture:** KernelSU-Next v3.4.2 + SUSFS at ring-0, Binder-level HMA OSS integration, and hardware attestation keybox spoofing capabilities.

---

## 📥 Official Download & Release Package

### UN1CA Carbon IX (v1.0) — Galaxy S23 Base (`SM-S911B` / `dm1q`) ONLY

> **⚠️ DEVICE NOTICE:** This release package is strictly engineered and calibrated for the **Samsung Galaxy S23 Base (`SM-S911B` / `dm1q`)** running **FIRMWARE BIT A**. Do not flash on other Galaxy models or Ultra variants (`dm3q`).

| Release Parameter | Specification / Value |
| :--- | :--- |
| **Release Tag** | `IX-v1.0` |
| **Android Version** | Android 17 (One UI 9.0 • SDK 37) |
| **Source Firmware** | `S911BXXUAZZI8` (Official Samsung Base) |
| **Firmware Bit / Binary** | **FIRMWARE BIT A** (`SW REV: A` / Binary A / U10 / SA) |
| **Target Device** | Samsung Galaxy S23 (`SM-S911B` / `dm1q`) |
| **Linux Kernel** | GoRhanHee 5.15.216 + KernelSU-Next v3.4.2 + SUSFS |
| **Recovery** | Team Win Recovery Project (TWRP 3.7.1_12-0) integrated |
| **Encryption Type** | Authentic Samsung Hardware FBE v2 (No DFE hack) |
| **Package Filename**| `UN1CA_Carbon_IX_1.0_dm1q_ZZI8.zip` |
| **Package Size** | **8.05 GB** (8,644,680,502 bytes) |
| **SHA-1 Checksum** | `2c639ccf447eebe479482408ccf05157c9db29a6` |
| **SHA-256 Checksum**| `eccace0f815258597a7ff35c6f6a45961f11992e35e8142a19e83c626c367f9d` |
| **Download Mirror** | 🔗 **[Google Drive (Official Release Mirror)](https://drive.google.com/file/d/12n76Q7DNkFw9zbyqrgREkDOJSfZDKoff/view?usp=sharing)** |

---

## 📲 Clean Installation Guide (TWRP Recovery)

> **⚠️ CRITICAL PRE-REQUISITE (FIRMWARE BIT A MANDATORY):**  
> Your device **MUST** already be running an official **Bit A (U10 / SA)** firmware base before flashing this ROM. If you attempt to flash UN1CA Carbon directly over an older bootloader base (such as Bit 9 or legacy Android 14/15/16 builds), partition and driver mismatches will cause an immediate crash and bootloop.  
>  
> For a 100% clean, error-free setup, we strongly recommend flashing the base Odin firmware first:  
> 🔗 **[One UI 9.0 (A17) Odin-Flashable Beta Firmware (S23 Series DS ZZI8 Bit A - XDA)](https://xdaforums.com/t/one-ui-9-0-a17-odin-flashable-beta-firmware-s23-series-ds-zzi8-bit-a.4725866/)**

### Step-by-Step Installation Workflow:

1. **Flash Stock One UI 9.0 Bit A Firmware:**  
   - Download the Odin-flashable One UI 9.0 (`ZZI8` Bit A) firmware from the link above.  
   - Flash it completely via Odin to update all underlying bootloader, modem, and vendor partitions.
2. **First Boot:**  
   - Let the stock base boot fully into the setup wizard at least once, then power off the device.
3. **Flash TWRP Recovery:**  
   - Boot into Download Mode and flash TWRP Recovery (`recovery.tar`) via Odin.
4. **Wipe & Format Data (Mandatory):**  
   - Boot directly into TWRP Recovery.  
   - Go to **Wipe > Format Data**, type `yes`, and confirm. *(Required to properly initialize authentic FBE v2 encryption metadata structures).*
5. **Flash UN1CA Carbon:**  
   - Transfer `UN1CA_Carbon_IX_1.0_dm1q_ZZI8.zip` to your internal storage via USB/MTP, USB-OTG, or use `adb sideload`.  
   - Navigate to **Install**, select the ROM zip, and swipe to confirm.  
   - *(The installer writes system partitions, flashes the GoRhanHee kernel, preserves TWRP recovery, and places `KernelSU_Next.apk` onto `/sdcard/`).*
6. **Reboot:**  
   - Tap **Reboot System**. Enjoy UN1CA Carbon IX!
   - *(Optional: If the device hangs on first boot after flashing, boot back into TWRP, execute **Format Data** (`yes`) one more time, and reboot).*

---
> [!CAUTION]
> **⚠️ CRITICAL RISK OF PERMANENT BOOTLOADER LOCK / USE ONLY THE PROVIDED LINK:**  
> If you follow the procedure exactly as described using the provided files, **this will NOT relock your Bootloader (BL)**.  
> However, if you attempt to install a **pure, official Samsung STOCK ROM** (via Smart Switch, Frija, or SamFirm), **YOUR BOOTLOADER WILL BE AUTOMATICALLY RELOCKED**, and you will **permanently lose** the ability to flash custom software, recoveries, and ROOT on your device!  
>  
> The link provided below **already includes the patched STOCK ROM specifically modified to PREVENT bootloader relocking**:  
> 🔗 **[One UI 9.0 (A17) Odin-Flashable Patched Beta Firmware (S23 Series DS ZZI8 Bit A - XDA)](https://xdaforums.com/t/one-ui-9-0-a17-odin-flashable-beta-firmware-s23-series-ds-zzi8-bit-a.4725866/)**
## ⚠️ Bootloop Troubleshooting & Mandatory Base Firmware Guide

If you experience a **bootloop** or hung boot screen after flashing, it means your device's low-level radio, vendor, or bootloader partitions are out of sync with the One UI 9.0 Bit A base. Follow this verified remediation procedure:

1. **Flash Base Odin Firmware:** Flash the official One UI 9.0 Beta (`ZZI8` Bit A) firmware package via Odin:  
   🔗 **[One UI 9.0 (A17) Odin-Flashable Beta Firmware (S23 Series DS ZZI8 Bit A - XDA)](https://xdaforums.com/t/one-ui-9-0-a17-odin-flashable-beta-firmware-s23-series-ds-zzi8-bit-a.4725866/)**
2. **First Boot:** Let the stock base firmware boot into the initial setup wizard at least once to initialize hardware nvram and modem partitions, then power off the device.
3. **Reflash TWRP Recovery:** Enter Download Mode and flash TWRP Recovery (`recovery.tar`) via Odin.
4. **Wipe & Install Carbon:** Boot directly into TWRP, perform **Wipe > Format Data** (type `yes`), copy `UN1CA_Carbon_IX_1.0_dm1q_ZZI8.zip` to the device, and flash the package.
5. **Post-Flash Verification:** If the device still bootloops after flashing the zip, reboot into TWRP, perform **Format Data** (`yes`) one more time, and reboot to system. The system will boot normally.

---

## 🛠️ Roadmap to Stable & Known Issues

We are actively developing the next maintenance release to graduate UN1CA Carbon from experimental beta to a full **Stable** channel release.

### Known Issues in Current Release (Actively Being Fixed for Next Build)
- **Samsung Account Disconnects:** Background account session tokens may occasionally invalidate, causing unexpected logout prompts.
- **SmartManager Force Closes:** Intermittent crashes when opening specific battery and storage optimization tabs in Device Care / SmartManager.

> **💬 Community Feedback:** Bug reports, logcats (`adb logcat -b all -d > logcat.txt`), and dmesg outputs are always highly appreciated! Please open an issue on our GitHub repository or join our Telegram group to help refine upcoming builds for everyone.

---

## 🏛️ Upstream Lineage & Pinned Commit Hashes

UN1CA Carbon is built upon a transparent, modular foundation combining upstream core engines, community enhancements, and custom ALRI engineering:

| Component / Layer | Upstream Project | Branch / Tag | Pinned Commit Hash |
| :--- | :--- | :---: | :--- |
| **Custom Kernel Engine** | [GoRhanHee](https://github.com/GoRhanHee) | `main` | `Linux 5.15.216` (SM8550 + SUSFS) |
| **Root Solution** | [rifsxd/KernelSU-Next](https://github.com/rifsxd/KernelSU-Next) | `v3.4.2` | `33355` (Next-gen LKM) |
| **Recovery Engine** | [TeamWin/TWRP](https://github.com/TeamWin) | `android-12.1` | `3.7.1_12-0_archer` (`dm1q`) |
| **One UI 9 Framework Engine** | [Rezoss-Reza/UN1CA](https://github.com/Rezoss-Reza) | `sembilan` | [`9212d8fd95444cee0f28a7af8dff8e96f18555fb`](https://github.com/Rezoss-Reza/UN1CA/commit/9212d8fd95444cee0f28a7af8dff8e96f18555fb) |
| **Visual Assets & Wallpapers** | [cosinemyan/NPLROM_UN1CA](https://github.com/cosinemyan) | `npl-oneui9` | [`d859c51e78916299f76ffeea0e9820123fd67d3a`](https://github.com/cosinemyan/NPLROM_UN1CA/commit/d859c51e78916299f76ffeea0e9820123fd67d3a) |
| **UN1CA Core Engine** | [salvogiangri/UN1CA](https://github.com/salvogiangri) | `sixteen` / `3.2.1` | [`0c2ea1d61ddc78ae8e6900787f9f9e7269b7b439`](https://github.com/salvogiangri/UN1CA/commit/0c2ea1d61ddc78ae8e6900787f9f9e7269b7b439) / [`9f8add9e`](https://github.com/salvogiangri/UN1CA/commit/9f8add9e7fbb60ad4bb13704cb8ffa1f882f0edc) |
| **Port, S23 Base Fixes & Carbon Core** | [alrigroup/un1ca-carbon](https://github.com/alrigroup/un1ca-carbon) | `main` | *HEAD (ALRI Development)* |

---

## 🚀 Complete Feature Catalog

Below is the comprehensive technical registry of all modifications, modules, and platform capabilities included in this release:

### ⚙️ 1. Native "Carbon Settings" Menu (`SecSettings.apk`)
Accessible directly at the top level of the primary Samsung Settings app:
- **Allow Application Downgrade:** Allows installing older versions of any application without uninstalling the current package (no data loss).
- **Disable Signature Verification (CorePatch):** System-level APK signature verification bypass, enabling execution of modified or patched system applications.
- **Disable Low Target SDK Block:** Enables installation of legacy applications built for older Android releases (Android 5, 6, 7).
- **Disable ASKS (Advanced Samsung Knox Security):** Suppresses Samsung's background application restriction daemon.
- **Secure Screenshot:** Unlocks screen captures and video recordings inside protected applications (banking, media streaming, secure chats).
- **Disable Capture Detection:** Prevents applications from detecting when screenshots or screen recordings are captured.
- **Authentic Mock Location:** Masks mock location attributes without triggering detection from security-sensitive services.
- **Unlimited Google Photos Storage:** Automated device profile spoofing for unlimited original-quality backups in Google Photos.
- **Unlock Higher FPS in Games (GamesProps):** Profile spoofing to unlock 90 FPS and 120 FPS high refresh rate modes in competitive titles.
- **Spoof as S26 Ultra on Galaxy Store:** Instructs the Galaxy Store client to expose latest-generation apps and neural services.
- **Galaxy Themes Infinite Trial:** Disables the 10-minute trial expiration timer on Galaxy Store themes, making trial themes permanent.
- **Now Nudge (Galaxy AI Replies):** Experimental contextual smart reply suggestions powered by Galaxy AI.
- **SCPM Allowlist Policy Bypass:** Allows local clients to bypass regional, CSC, and country gating for AI audio and neural features.

---

### 🎨 2. Interface, Display & Visual Customizations
- **Native 120Hz Display (Zero Flickering):** Calibrated specifically for the flat FHD+ (1080x2340) AMOLED panel of the Galaxy S23 base model (`HFR Mode 2`).
- **Force Peak Refresh Rate:** Toggle to enforce a constant 120Hz display refresh rate under all ambient lighting conditions.
- **Live Blur Effect (Native Blur):** Real-time Gaussian background blur rendered across Samsung One UI window surfaces.
- **Launcher Animation Type:** Customizable Samsung One UI Home animation velocity and easing curves.
- **Vulkan Graphics Engine:** Direct hardware UI rendering pipeline over Vulkan for maximal fluidity.
- **Outdoor Mode:** Exposes maximum solar-boost brightness levels directly in Display Settings.
- **UN1CA Font Selector:** Custom font selection engine integrated natively into *Display > Font*, supporting Monotype and SamsungSans font collections.
- **Synchronized Lockscreen & AOD Font Engine:** Automatically mirrors selected custom font typography to the lockscreen clock and Always On Display.
- **Sagarmatha Wallpaper Suite (NPL Pack):** Direct injection of high-resolution photographic wallpapers into `wallpaper-res.apk`.
- **Galaxy S25 Paradigm Wallpapers:** Integrated animated live wallpapers from the Galaxy S25 series.

---

### 🛡️ 3. Privacy, Security & Anti-Detection
- **Integrated HMA OSS (Hide My Applist):** Privacy protection hooks embedded at the Android Binder IPC level, preventing applications from querying other installed packages.
- **Hardware Attestation Spoof (Keybox):** Allows importing custom cryptographic keyboxes to pass Google hardware-backed attestation checks.
- **Dynamic Play Integrity Fix (PIF):** Automated property injection ensuring device integrity certification across Google Play and Google Wallet.
- **Hide Developer Status:** Masks developer options and USB debugging state from detection-sensitive banking apps.
- **4-Digit Auto-Confirm PIN:** Instantly unlocks the device upon entering the fourth digit without requiring the "OK" confirmation touch.
- **Advanced Power Menu:** Native reboot shortcuts for **Recovery (TWRP)**, **Download Mode**, and **Fastboot** accessible from the power off dialog.

---

### 📞 4. Telephony, Audio & Productivity
- **Native Call Recording:** High-definition voice call recording embedded directly into the Samsung Phone dialer (`ril.call.recording=true`), with zero audible recording disclaimers.
- **Dual Messenger & Multi-App Cloning:** Stable Samsung Dual Messenger support for multiple messaging and social accounts without APK assembly conflicts.
- **Multi-User Support:** Enables secondary user profiles and guest accounts across Samsung One UI.
- **Custom Boot & Call Audio:** Custom boot audio playback and vintage Samsung call connection/disconnection tones (2018, 2024, ACH Galaxy Bells).

---

### 🔋 5. Battery & Power Efficiency
- **Battery Health & Charge Cycle Counter:** Real-time battery capacity degradation percentage and cycle count statistics exposed in Settings across all global CSC regions.
- **Stingy Presets (Aggressive Power Saving):** Fine-grained background process freeze profiles in Maximum Power Saving mode, disabling redundant telemetry and background sync wakelocks.

---

### 🛠️ 6. Core Engineering & System Architecture (ALRI Carbon Layer)
- **Hardware-Backed File-Based Encryption (FBE):** Preserves authentic Samsung One UI 9 FBE storage security on UFS 4.0 (`/dev/block/sda41`), avoiding the fatal `vold` daemon crashes and black-screen hangs caused by legacy `encryptable` hacks, while ensuring full compatibility with TWRP recovery formatting.
- **Integrated GoRhanHee Kernel (Linux 5.15.216):** High-performance Snapdragon 8 Gen 2 kernel pre-packaged with KernelSU-Next v3.4.2 and SUSFS, fully synchronized with matching DLKM drivers.
- **Automated TWRP Recovery Flashing:** Preserves and flashes the official Team Win Recovery Project (`recovery.img`) directly in the installer package.
- **Reinforced SurfaceFlinger:** Corrected dynamic linker binding against Samsung Snapdragon 8 Gen 2 native `libbase.so` (`fmt::v12`), eliminating fatal display compositor crashes (`CANNOT LINK EXECUTABLE`).
- **Official Samsung Keyboard (`HoneyBoard`):** Original Samsung certificate (`CN=Samsung Cert`) and `oat/arm64` ahead-of-time compiled binaries preserved, ensuring instant keyboard rendering during FRP-protected initial device setup.
- **Hardware TrustZone Lockdown Guard:** Strict preservation of `KnoxGuard.apk` and `com.samsung.android.kgclient` permissions, preventing TrustZone hardware lockouts (`tz_kg`).
- **AVB Bootloader Protection:** The OTA installer updates dynamic logical partitions within `super` (`system`, `vendor`, `product`, `system_ext`, `odm`), preserving existing verified bootloader states.
- **Single System Image (QSSI) over EROFS:** System logical partitions built with transparent compression via `erofs`, saving disk space and reducing RAM overhead during boot.

---

## 🤝 Open Source, Non-Profit & Community Contributions

**UN1CA Carbon is built 100% for the community as a strictly non-profit, open-source initiative.**

We firmly believe in community-driven development, transparency, and freedom of choice. **Any and all contributions are 100% welcome!** Whether you are submitting pull requests, testing builds, reporting edge-case bugs, improving kernel parameters, optimizing battery profiles, translating interfaces, or contributing device trees for other Galaxy models — your participation is deeply valued.

Feel free to open issues, submit pull requests, or share feedback. Let's push custom Android firmware forward together.

---

## 🛡️ Root Access & KernelSU-Next Management

UN1CA Carbon integrates the **GoRhanHee Custom Kernel (Linux 5.15.216)** with **KernelSU-Next** and **SUSFS** built directly into the kernel driver at ring 0.

### Recommended Manager Installation
To grant and manage superuser permissions, users should install the official KernelSU-Next Manager:
- **Official Release:** [KernelSU-Next v3.4.2](https://github.com/KernelSU-Next/KernelSU-Next/releases/tag/v3.4.2)
- **Standard vs. Spoofed Package:** The choice between the standard release APK (`KernelSU_Next_v3.4.2_33355-release.apk`) and the spoofed manager package is **100% up to the user** based on personal preferences, banking detection evasion strategies, and hiding configurations.
- **Offline Convenience:** During ROM installation, the flashable installer automatically extracts the official untouched KernelSU-Next APK to `/sdcard/KernelSU_Next.apk` so it is immediately accessible for installation without requiring internet access.

---

## ⚙️ Carbon Engine — Next-Generation Build System (Prototype Status)

Located in `carbon_engine/`, **Carbon Engine** is our vision for the future of custom ROM compilation.

### 🧪 Current Status: PROTOTYPE (Under Active Development)
- **What is ready:** The native **C++20** engine core—featuring OpenSSL SIMD composite fingerprinting, ACID SQLite3 build ledger (`ledger.db`), topological Kahn DAG resolution, and the asynchronous Process Supervisor—is fully compiled and achieves **100% pass rates across all unit tests** (`test_engine`).
- **Current Challenge & Production Reality:** Porting a massive, multi-vendor custom ROM (with over 49 legacy bash modules, APKTool hooks, and smali injectors) into a **100% content-addressed, phase-cached DAG** requires making every single patch idempotent. Because legacy scripts perform in-place mutations on decoded folders, running iterative phase caching directly on legacy scripts can cause resource collisions.
- **Current Production Compiler:** In this release, production flashable ZIPs are built using the highly optimized, 28-thread parallelized orchestrator (`make_carbon.sh`), which builds clean, deterministic packages in ~3 to 4 minutes.
- **The Long-Term Roadmap:** We are actively migrating legacy imperative scripts into declarative `Carbonfile.json` recipes. The ultimate goal is a universal compiler where altering a single string in Settings recompiles ONLY that APK and regenerates the flashable ZIP in **under 45 seconds**, completely eliminating redundant whole-ROM rebuilds. We invite developers interested in compiler engineering to collaborate with us!

---

## 🏛️ Modular Repository Architecture

```text
Un1ca_Carbon/
│
├── 📁 core_unica/            # UN1CA Foundation (Salvo Giangri): compiler toolchain, EROFS, OTA scripts
├── 📁 vendors_rezoss/        # One UI 9 Framework Engine (Rezoss-Reza): TEE-Sim, HMA OSS, 4-Certs Bypass
├── 📁 vendors_npl/           # Visual Enhancements (NPL Team): Sagarmatha Wallpapers, ThemeCenter Trial
│
├── 📁 carbon_engine/         # C++20 NATIVE BUILD ORCHESTRATOR & DAG ENGINE (PROTOTYPE)
│   ├── CMakeLists.txt        # Modern CMake C++20 build definition
│   ├── Carbonfile.json       # Declarative 160-step universal build recipe
│   ├── make_carbon_engine.sh # Self-compiling build entrypoint
│   └── src/                  # Engine sources (DAG, SQLite3 Ledger, OpenSSL Hasher, Supervisor)
│
├── 📁 carbon_ours/           # ALRI DEVELOPMENT EXCLUSIVE ENGINEERING
│   ├── target_dm1q/          # S23 Hardware Calibration: Flat FHD+ (1080x2340), HFR Mode 2, Super Partition
│   ├── branding_settings/    # SecSettings with native "Carbon Settings" menu, molecular icon & credits
│   ├── bootanimation/        # Custom UN1CA Carbon boot animation (24fps intro + breathing pulse loop)
│   ├── telemetry_debloat/    # Configurable Telemetry Debloater controlled via DEBLOAT_TELEMETRY
│   ├── kernel_engine/        # Combo integration engine for GoRhanHee Kernel, DLKM drivers, and TWRP
│   ├── kernel_gorhanhee/     # GoRhanHee Linux 5.15.216 kernel Image & matching DLKM drivers
│   ├── prebuilt_apps/        # Pre-installed KernelSU-Next v3.4.2 manager package
│   ├── recovery_twrp/        # Built-in TWRP Recovery image (split into recovery.img.00/.01 under 55 MB for GitHub compliance)
│   ├── wallpapers/           # Carbon official wallpapers (static FHD+ & animated lockscreen video)
│   └── security_keys/        # Platform and testkey signature credentials
│
├── 📁 docs/                  # Technical Documentation & Architectural Specifications
│   ├── engineering_report.md # Forensic Engineering Report detailing every resolved failure & bootloop
│   ├── telemetry_debloat.md  # Complete telemetry debloater specification & toggle guide
│   └── debloat_inventory.md  # Complete binary audit of all 340 default rootfs APK packages
│
├── 📄 make_carbon.sh         # Modular automated build orchestrator
├── 📄 README.md              # Project documentation & feature specifications
└── 📄 LICENSE                # ARGLP (ALRI Group License Permissive)
```

---

## 📚 Developer Guides & Engineering Specifications

For maintainers, developers, and porters extending UN1CA Carbon, comprehensive technical documentation is available under [`docs/dev_guides/`](docs/dev_guides/):

1. **[Carbon Engine Architecture](docs/dev_guides/01_CARBON_ENGINE_ARCHITECTURE.md):** Deep dive into the native C++20 build orchestrator, Process Supervisor, SQLite ledger, and the 9 macroscopic pipeline stages.
2. **[Porting UN1CA Scripts to Engine](docs/dev_guides/02_PORTING_UN1CA_SCRIPTS_TO_ENGINE.md):** Step-by-step tutorial on translating legacy imperative bash scripts (`customize.sh`, `apply_modules.sh`) into declarative `Carbonfile.json` actions, multi-target macros, and idempotency patterns.
3. **[DAG Caching & SQLite Ledger](docs/dev_guides/03_DAG_CACHING_AND_LEDGER.md):** Detailed guide on OpenSSL SHA-256 fingerprinting, cache invalidation, topological task ordering, and incremental phase skipping.
4. **[Boot Animation & Graphics Subsystem](docs/dev_guides/04_BOOTANIMATION_AND_GRAPHICS_SUBSYSTEM.md):** Architecture of Frame-0 SurfaceFlinger rendering, removal of Samsung QMG daemons, and runtime dynamic switching between Carbon and Android 17.

---

## 👥 Credits & Acknowledgements

* **Organization & Official Maintainer:** **ALRI Development** ([ALRIGROUP](https://github.com/alrigroup))
* **Lead Maintainer & Lead Developer:** **Alexsander "AlexsAR" ALRI** ([@alexsanderalri](https://github.com/alexsanderalri))
* **Port, Systems & Display Engineering:** **ALRI Development**
* **Custom Kernel (Linux 5.15.216):** **GoRhanHee** ([@GoRhanHee](https://github.com/GoRhanHee)) — High-performance Snapdragon 8 Gen 2 kernel with SUSFS & KernelSU integration
* **Root Solution (KernelSU-Next):** **rifsxd** ([@rifsxd](https://github.com/rifsxd)) & [KernelSU-Next Contributors](https://github.com/rifsxd/KernelSU-Next), based on KernelSU by **tiann** ([@tiann](https://github.com/tiann))
* **Custom Recovery (TWRP):** [Team Win Recovery Project](https://github.com/TeamWin) ([twrp.me](https://twrp.me)) & Galaxy S23 maintainers ([@archer9634](https://github.com/archer9634))
* **One UI 9 Framework Engine:** [@Rezoss-Reza](https://github.com/Rezoss-Reza)
* **UN1CA Core Architecture:** Salvo Giangri ([@salvogiangri](https://github.com/salvogiangri))
* **Visuals & Wallpapers:** [@cosinemyan](https://github.com/cosinemyan) (NPL ROM Team)
* **Official Repository:** [https://github.com/alrigroup/un1ca-carbon](https://github.com/alrigroup/un1ca-carbon)

---

## 📄 Open Source Licensing

This project implements a transparent licensing structure honoring upstream authorship:

* **ALRI Engineering, Calibrations & Carbon Modules (`carbon_ours/`):**  
  Licensed under the **ARGLP — ALRI GROUP LICENSE PERMISSIVE**  
  Available in the `LICENSE` file and at: [https://github.com/alrigroup/licenses](https://github.com/alrigroup/licenses).
* **UN1CA Core Engine (`core_unica/`):**  
  Maintains its original **GNU General Public License v3.0 (GPL-3.0)** by Salvo Giangri.
* **Upstream Contributions (`vendors_rezoss/` and `vendors_npl/`):**  
  Retain their respective licenses and copyright notices attributed to @Rezoss-Reza and @cosinemyan.
