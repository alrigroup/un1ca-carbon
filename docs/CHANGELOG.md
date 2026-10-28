# 📜 UN1CA Carbon — Changelog & Version History

This document catalogs the complete technical changelog and historical evolution of **UN1CA Carbon IX** across releases.

---

## 🚀 UN1CA Carbon IX v1.1 (Current Production Release)
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
