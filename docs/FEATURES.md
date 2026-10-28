# ⚙️ UN1CA Carbon — Complete Feature Catalog

Below is the exhaustive technical registry of every modification, optimization, and platform capability integrated into **UN1CA Carbon IX**.

---

## 🎛️ 1. Native "Carbon Settings" Menu (`SecSettings.apk`)
Accessible directly on the primary dashboard of Samsung Settings:

* **Carbon Performance Engine Selector:** Real-time dropdown selector allowing on-the-fly switching between 3 performance modes:
  * 🍃 **Light Mode:** Clamps Prime Cortex-X3 to 1.97 GHz and Adreno 740 GPU to 348 MHz for maximum battery preservation and ice-cold thermals.
  * ⚖️ **Normal Mode:** Factory stock Snapdragon 8 Gen 2 for Galaxy frequencies governed by Qualcomm `walt`.
  * 🔥 **Performance Mode:** Eliminates governor ramp-up latency (`up_rate_limit_us=0`), enables aggressive Adreno 740 clock floors, and boosts UFS read-ahead I/O to 512 KB.
* **SmartView & Wireless DeX HDCP Bypass:** Native bypass (`wlan.wfd.hdcp=disable`) enabling wireless projection to Smart TVs and PCs on Knox 0x1 bootloaders.
* **ZRAM ZSTD Memory Optimizer:** 8 GB Swap backed by high-speed native **ZSTD compression** (`swappiness=100`), retaining dozens of background applications without reloads.
* **Allow Application Downgrade:** Allows installing older versions of any APK without uninstalling the current package (preserves all user data).
* **Disable Signature Verification (CorePatch):** System-level APK signature verification bypass, enabling execution of modified or patched system applications.
* **Disable Low Target SDK Block:** Enables installation of legacy applications built for older Android releases (Android 5, 6, 7).
* **Disable ASKS (Advanced Samsung Knox Security):** Suppresses Samsung's background application restriction daemon.
* **Secure Screenshot:** Unlocks screen captures and video recordings inside protected applications (banking, media streaming, secure chats).
* **Disable Capture Detection:** Prevents applications from detecting when screenshots or screen recordings are captured.
* **Authentic Mock Location:** Masks mock location attributes without triggering detection from security-sensitive services.
* **Unlimited Google Photos Storage:** Automated device profile spoofing for unlimited original-quality backups in Google Photos.
* **Unlock Higher FPS in Games (GamesProps):** Profile spoofing to unlock 90 FPS and 120 FPS high refresh rate modes in competitive titles.
* **Spoof as S26 Ultra on Galaxy Store:** Instructs the Galaxy Store client to expose latest-generation apps and neural services.
* **Galaxy Themes Infinite Trial:** Disables the 10-minute trial expiration timer on Galaxy Store themes, making trial themes permanent.
* **Now Nudge (Galaxy AI Replies):** Contextual smart reply suggestions powered by Galaxy AI.
* **SCPM Allowlist Policy Bypass:** Allows local clients to bypass regional, CSC, and country gating for AI audio and neural features.

---

## 🎨 2. Interface, Display & Visual Customizations
* **Native 120Hz Display (Zero Flickering):** Calibrated specifically for the flat FHD+ (1080x2340) AMOLED panel of the Galaxy S23 base model (`HFR Mode 2`).
* **Force Peak Refresh Rate:** Toggle to enforce a constant 120Hz display refresh rate under all ambient lighting conditions.
* **Live Blur Effect (Native Blur):** Real-time Gaussian background blur rendered across Samsung One UI window surfaces.
* **Launcher Animation Type:** Customizable Samsung One UI Home animation velocity and easing curves.
* **Vulkan Graphics Engine:** Direct hardware UI rendering pipeline over Vulkan for maximal fluidity.
* **Outdoor Mode:** Exposes maximum solar-boost brightness levels directly in Display Settings.
* **UN1CA Font Selector:** Custom font selection engine integrated natively into *Display > Font*, supporting Monotype and SamsungSans font collections.
* **Synchronized Lockscreen & AOD Font Engine:** Automatically mirrors selected custom font typography to the lockscreen clock and Always On Display.
* **Sagarmatha Wallpaper Suite (NPL Pack):** Direct injection of high-resolution photographic wallpapers into `wallpaper-res.apk`.
* **Galaxy S25 Paradigm Wallpapers:** Integrated animated live wallpapers from the Galaxy S25 series.
* **Dynamic Boot Animation Switcher:** Switch between the exclusive **Carbon Animated Suite** and classic One UI / Rezoss boot animations directly from Settings, accompanied by custom vintage boot audio playback.

---

## 🧠 3. Privacy-First On-Device AI (Qwen 2.5 LLM)
Unlike proprietary cloud AI features that stream private texts, notes, and browsing history to remote third-party data centers, **UN1CA Carbon implements an on-device local intelligence engine**:
* **100% Offline Execution:** Runs Qwen 2.5 Instruct neural models entirely within device silicon via the Snapdragon 8 Gen 2 Hexagon NPU and Adreno 740 GPU.
* **Zero Telemetry & Zero Cloud Dependency:** Prompts, summaries, and outputs never leave the physical device.
* **In-Settings Management Dashboard:** Displays engine operational status, local storage paths, and provides a direct model download trigger with SHA-256 integrity verification.
* **Writing Toolkit Integration:** Powers conversational tone adjustments and Smart Suggestions across messaging applications.

---

## ⚡ 4. Advanced GPU Tuning (Adreno 740)
* **KonaBess C++ Engine:** Native binary (`/system/bin/unica-gpu`) with live settings dashboard.
* **Dynamic Voltage & Clock Curves:** Allows modifying physical GPU tables and voltage curves for enhanced gaming efficiency or power throttling.
* **Automated TWRP Rollback Safety:** Automatically writes a backup recovery partition before applying table modifications, ensuring brick-safe GPU tuning.

---

## 📞 5. Telephony, Audio & Productivity
* **Native Call Recording:** High-definition voice call recording embedded directly into the Samsung Phone dialer (`ril.call.recording=true`), with zero audible recording disclaimers.
* **Bixby Text Call Telephony Routing:** Fixed Qualcomm audio policy routing blocks by authorizing `AUDIO_CHANNEL_OUT_MONO` and 32 kHz sampling rates on `incall_music_uplink` and `voice_tx`.
* **Audio Eraser & SoundAlive 2025:** Neural voice/noise separation engines (`libmultisourceseparator.so`) and updated Galaxy 2025 acoustic profile.
* **Dual Messenger & Multi-App Cloning:** Stable Samsung Dual Messenger support for multiple messaging and social accounts without APK assembly conflicts.
* **Multi-User Support:** Enables secondary user profiles and guest accounts across Samsung One UI.
* **Custom Boot & Call Audio:** Custom boot audio playback and vintage Samsung call connection/disconnection tones (2018, 2024, ACH Galaxy Bells).

---

## 🔋 6. Battery & Power Efficiency
* **Battery Health & Charge Cycle Counter:** Real-time battery capacity degradation percentage and cycle count statistics exposed in Settings across all global CSC regions.
* **Stingy Presets (Aggressive Power Saving):** Fine-grained background process freeze profiles in Maximum Power Saving mode, disabling redundant telemetry and background sync wakelocks.

---

## 🛠️ 7. Core Engineering & System Architecture (ALRI Carbon Layer)
* **Hardware-Backed File-Based Encryption (FBE):** Preserves authentic Samsung One UI 9 FBE storage security on UFS 4.0 (`/dev/block/sda41`), avoiding the fatal `vold` daemon crashes and black-screen hangs caused by legacy `encryptable` hacks, while ensuring full compatibility with TWRP recovery formatting.
* **Integrated GoRhanHee Kernel (Linux 5.15.216):** High-performance Snapdragon 8 Gen 2 kernel pre-packaged with KernelSU-Next v3.4.2 and SUSFS, fully synchronized with matching DLKM drivers.
* **Automated TWRP Recovery Flashing:** Preserves and flashes the official Team Win Recovery Project (`recovery.img`) directly in the installer package.
* **Reinforced SurfaceFlinger:** Corrected dynamic linker binding against Samsung Snapdragon 8 Gen 2 native `libbase.so` (`fmt::v12`), eliminating fatal display compositor crashes (`CANNOT LINK EXECUTABLE`).
* **Official Samsung Keyboard (`HoneyBoard`):** Original Samsung certificate (`CN=Samsung Cert`) and `oat/arm64` ahead-of-time compiled binaries preserved, ensuring instant keyboard rendering during FRP-protected initial device setup.
* **Hardware TrustZone Lockdown Guard:** Strict preservation of `KnoxGuard.apk` and `com.samsung.android.kgclient` permissions, preventing TrustZone hardware lockouts (`tz_kg`).
* **AVB Bootloader Protection:** The OTA installer updates dynamic logical partitions within `super` (`system`, `vendor`, `product`, `system_ext`, `odm`), preserving existing verified bootloader states.
* **Single System Image (QSSI) over EROFS:** System logical partitions built with transparent compression via `erofs`, saving disk space and reducing RAM overhead during boot.
