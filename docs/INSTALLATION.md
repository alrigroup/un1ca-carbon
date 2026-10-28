# 📲 UN1CA Carbon — Step-by-Step Installation Guide

This guide details the complete flashing procedure for **UN1CA Carbon IX** on the Samsung Galaxy S23 Base (`SM-S911B` & `SM-S9110` / `dm1q`).

---

## ⛔ CRITICAL NOTICE: Identify Your Device Scenario First

> **⚠️ WARNING BEFORE PROCEEDING:**  
> If you follow the instructions below using our provided packages, **your Bootloader (BL) will NOT be relocked**.  
> However, **DO NOT flash an unmodified, pure official Samsung Stock ROM** from Frija, SamFirm, or Smart Switch! Doing so will **FORCE RELOCK YOUR BOOTLOADER**, resulting in the **PERMANENT LOSS** of your ability to use custom ROMs, TWRP, and Root on One UI 9! Always follow the instructions below.

---

### 🟢 Scenario A: You Are ALREADY on Firmware Bit A (One UI 9 / Android 17 Base)
*Use this workflow if your phone is already on a Bit A base (e.g. ZZI8, GZIF or previous One UI 9 builds):*

1. **Boot into TWRP Recovery:** Power off your device, connect to PC via USB, hold `Volume Up + Power` until TWRP launches.
2. **Format Userdata (Crucial):** Go to **Wipe > Format Data**, type `yes`, and confirm. *(Mandatory to initialize clean FBE v2 encryption metadata structures).*
3. **Flash UN1CA Carbon:**
   * **Via Storage:** Copy `UN1CA_Carbon_IX_1.1_dm1q_GZIF.zip` to internal storage or USB-OTG drive, tap **Install**, select the file, and swipe to flash. **OR**
   * **Via ADB Sideload:** In TWRP, go to **Advanced > ADB Sideload**, swipe to start, and run from terminal:
     ```bash
     adb sideload UN1CA_Carbon_IX_1.1_dm1q_GZIF.zip
     ```
   > **⏳ CRITICAL ADB SIDELOAD BEHAVIOR NOTICE:**  
   > When using `adb sideload`, transmission progress on your PC terminal may appear to pause or stay at ~43%–47%. **IT HAS NOT CRASHED!** TWRP is actively decompressing and writing multiple gigabytes of uncompressed EROFS partitions directly to physical UFS blocks. **DO NOT UNPLUG OR REBOOT.** Wait patiently until the blue **"Reboot System"** button lights up on the device screen.
4. **Reboot:** Tap **Reboot System**. Enjoy UN1CA Carbon IX!

---

### 🔴 Scenario B: You Are on an Older Firmware BIT (Bit 8, Bit 9 or Android 14/15/16)
*If your phone is running an older bootloader base, you must upgrade your low-level hardware partitions to Bit A first without relocking your bootloader:*

1. **Download the Patched Bit A Odin Firmware:**  
   Download the modified One UI 9.0 Bit A firmware package (specifically patched to keep bootloader unlocked):  
   🔗 **[One UI 9.0 (A17) Odin-Flashable Patched Bit A Firmware (XDA)](https://xdaforums.com/t/rom-oneui-9-beta-s918b-s916b-s911b-port-dm3q-dm2q-dm1q.4688925/)**
2. **Flash via Odin:**
   * Put your device into **Download Mode** (power off, hold `Volume Up + Volume Down` and plug in USB).
   * In Odin, load the patched `BL`, `AP`, `CP`, `CSC` and `USERDATA_AIO` files into their respective slots.
   * Click **Start**.
3. **First Boot Handshake (Mandatory):** Let the patched stock base boot completely into the initial Welcome/Setup screen at least once. This step is mandatory to initialize hardware NVRAM, baseband modem, and TrustZone enclaves for Bit A. Then power off the device.
4. **Flash TWRP Recovery:** Enter Download Mode again and flash TWRP (`recovery.tar`) in the AP slot via Odin.
5. **Format Userdata:** Boot directly into TWRP, navigate to **Wipe > Format Data**, type `yes`, and confirm.
6. **Install UN1CA Carbon:** Flash `UN1CA_Carbon_IX_1.1_dm1q_GZIF.zip` via TWRP Install or `adb sideload` (observing the wait warning above).
7. **Reboot System:** Tap Reboot System.

---

## 🛡️ Root Access & KernelSU-Next Management

UN1CA Carbon integrates the **GoRhanHee Custom Kernel (Linux 5.15.216)** with **KernelSU-Next** and **SUSFS** built directly into the kernel driver at ring 0.

### Recommended Manager Installation
* **Official Release:** [KernelSU-Next v3.4.2](https://github.com/KernelSU-Next/KernelSU-Next/releases/tag/v3.4.2)
* **Standard vs. Spoofed Package:** The choice between standard release APK (`KernelSU_Next_v3.4.2_33355-release.apk`) and a spoofed manager package is **100% up to the user** based on banking app evasion preferences.
* **Offline Convenience:** During ROM installation, the flashable installer automatically extracts the official untouched KernelSU-Next APK to `/sdcard/KernelSU_Next.apk` so it is immediately accessible for installation without requiring internet access.

---

## 🧩 Recommended KernelSU Modules Suite

To achieve **100% test pass rates across all verification suites**, complete banking app stealth, and total root invisibility, we officially recommend the following curated module stack:

| Recommended Module | Purpose & Role | Repository Link |
| :--- | :--- | :---: |
| **Hybrid Mount (OverlayFS)** | **Fundamental Requirement:** Employs native Linux `OverlayFS` instead of legacy magic mount, guaranteeing crash-free module loading on One UI 9. | [meta-hybrid_mount](https://github.com/Hybrid-Mount/meta-hybrid_mount) |
| **SUSFS for KernelSU** | **Root & Kernel Stealth:** Userspace companion for the GoRhanHee kernel-level SUSFS driver, masking root, mounts, and bootloader status. | [susfs4ksu-module](https://github.com/sidex15/susfs4ksu-module) |
| **TrickyStoreOSS** | **Hardware Keystore Interceptor:** Intercepts Keystore attestation requests to inject valid certificate chains. | [TrickyStoreOSS](https://github.com/beakthoven/TrickyStoreOSS) |
| **Integrity-Box** | **Play Integrity Certification:** Works alongside TrickyStore to guarantee full attestation passes with automated fingerprint updates. | [Integrity-Box](https://github.com/MeowDump/Integrity-Box) |
| **ZygiskNext** | **Standalone Zygisk Layer:** High-performance Zygote injection architecture built specifically for modern KernelSU setups. | [ZygiskNext](https://github.com/LSPosed/ZygiskNext) |
| **Vector Xposed Framework** | **Modern LSPosed Successor:** High-performance ART/Xposed framework optimized for Android 15/16/17 (One UI 9.0) runtime hooks. | [Vector](https://github.com/JingMatrix/Vector) |
