# 👑 UN1CA Carbon

<div align="center">

<img alt="UN1CA Carbon Banner" src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/banner.jpeg" width="100%"><br><br>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/logo_white.png">
  <source media="(prefers-color-scheme: light)" srcset="docs/assets/logo_dark.png">
  <img alt="UN1CA Carbon" src="docs/assets/logo_white.png" width="480">
</picture>

<br><br>

**Next-Generation One UI 9 Custom ROM for Samsung Galaxy S23 Series**  
*Release Version: **IX v1.1** (One UI 9.0 Stable • Android 17 • SDK 37)*  
*Engineered, Ported & Stabilized for Galaxy S23 Base (`SM-S911B` / `SM-S9110` / `dm1q`)*  
*Official Base Firmware: `S911BXXUAGZIF` (SW REV: A • Binary A)*  
*Cryptographic Signature: `OFFICIAL_CARBON_KEYS` (RSA 4096-bit ALRI GROUP)*

<br>

[![Android](https://img.shields.io/badge/Android-17-green.svg)](https://developer.android.com)
[![OneUI](https://img.shields.io/badge/OneUI-9.0--Stable-blue.svg)](https://www.samsung.com)
[![Device](https://img.shields.io/badge/Target-Galaxy%20S23%20(dm1q)-orange.svg)](https://github.com/alrigroup/un1ca-carbon)
[![Kernel](https://img.shields.io/badge/Kernel-GoRhanHee%205.15.216-red.svg)](https://github.com/alrigroup/un1ca-carbon)
[![Root](https://img.shields.io/badge/Root-KernelSU--Next-blueviolet.svg)](https://github.com/alrigroup/un1ca-carbon)
[![License](https://img.shields.io/badge/License-ARGLP-brightgreen.svg)](LICENSE)

</div>

---

## 📖 Overview

**UN1CA Carbon** is a customized and stabilized distribution of **Samsung One UI 9.0 Stable (Android 17 / SDK 37)** designed specifically to bring Samsung's latest software generation to the **Galaxy S23 Base (`SM-S911B` / `SM-S9110` / `dm1q`)**.

Built from official Samsung firmware, UN1CA Carbon combines enterprise security (private RSA-4096 keys), kernel-level stealth (KernelSU-Next + SUSFS), local privacy-first offline AI (Qwen 2.5), and deep hardware optimizations into a single seamless daily-driver package.

---

## 🌟 Key Highlights

* 📱 **Native S23 Flat Display Calibration:** 120Hz adaptive refresh rate with zero flickering (`HFR Mode 2`).
* 🔒 **Authentic FBE v2 Encryption:** Genuine Samsung Hardware File-Based Encryption preserved on UFS 4.0 storage without unstable DFE hacks.
* ⚡ **GoRhanHee Kernel (Linux 5.15.216):** Pre-packaged high-performance kernel with **KernelSU-Next v3.4.2** and **SUSFS** integrated out of the box.
* 🛡️ **Play Integrity Strong:** Passes `MEETS_BASIC_INTEGRITY`, `MEETS_DEVICE_INTEGRITY`, and `MEETS_STRONG_INTEGRITY` (0 detections on Native Detector & Duck Detector).
* 🔐 **Enterprise Private Signing:** Fully decoupled from public AOSP test-keys; signed with ALRI GROUP's 4-tier RSA 4096-bit keyset.
* 🧠 **On-Device Offline AI:** Integrated local **Qwen 2.5 LLM** running locally via Hexagon NPU and Adreno 740 GPU with 100% data privacy.
* 🎛️ **Carbon Performance Selector:** Native One UI dropdown in Settings for Light 🍃, Normal ⚖️, and Performance 🔥 modes.
* 📞 **Fixed Call Screening & Wireless DeX:** Unlocked Bixby Text Call audio routing, SoundAlive 2025, and permanent Miracast HDCP bypass.

---

## 📥 Downloads & Release Package

### Current Stable: UN1CA Carbon IX v1.1 (`dm1q` Universal)

| Parameter | Specification |
| :--- | :--- |
| **Target Device** | Samsung Galaxy S23 Base (`SM-S911B` & `SM-S9110` / `dm1q`) |
| **OS Version** | One UI 9.0 Stable (Android 17 • SDK 37) |
| **Required Firmware** | **FIRMWARE BIT A** (`SW REV: A` / Binary A) |
| **Base Firmware** | `S911BXXUAGZIF` (Official Samsung Base) |
| **Package Filename** | `UN1CA_Carbon_IX_1.1_dm1q_GZIF.zip` (8.04 GB) |
| **SHA-256 Checksum** | `cd77ec82803072cdba05b755ad7d5ff1d75ceaf4efe88281fe932a42d7ed5c8f` |
| **Direct Download** | 🔗 **[Download via Google Drive (Official Mirror)](https://drive.google.com/file/d/1unr3tUWE6bpBaLCgJuGhLvDMZ6jZrZIg/view?usp=sharing)** |
| **Official Release Folder**| 📂 **[Browse Google Drive Folder](https://drive.google.com/drive/folders/1ynY69aPsvnyndN2VqWr13NyqD6CTEvZn?usp=sharing)** |
| **Full Release Notes** | 📋 **[Read v1.1 Release Notes](docs/RELEASE_NOTES_v1.1.md)** |

---

## 📸 Verification & Screenshots

| Play Integrity (STRONG) | Duck Detector (Clean) | Native Detector (Clean) |
| :---: | :---: | :---: |
| <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/PIF.jpg" width="230"/> | <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/duck.jpg" width="230"/> | <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/native.jpg" width="230"/> |

| UN1CA Carbon Settings | Software Information (One UI 9.0) |
| :---: | :---: |
| <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/carbonsettings.jpg" width="230"/> | <img src="https://github.com/alrigroup/un1ca-carbon/releases/download/v1.1/info.jpg" width="230"/> |

---

## 📚 Documentation Index

To keep this main page clean, detailed technical specifications and guides have been organized into dedicated documents:

| Topic | Document | Description |
| :--- | :--- | :--- |
| ⚙️ **Features** | **[docs/FEATURES.md](docs/FEATURES.md)** | Complete catalog of all Settings toggles, UI features, audio, and AI capabilities. |
| 📲 **Installation** | **[docs/INSTALLATION.md](docs/INSTALLATION.md)** | Step-by-step flashing guides for Scenario A (Bit A) and Scenario B (older bits), TWRP, and Odin. |
| 📜 **Changelog** | **[docs/CHANGELOG.md](docs/CHANGELOG.md)** | Complete version history and changelogs from v1.0 to v1.1. |
| 🔐 **Security & Keys** | **[docs/SECURITY_AND_KEYS.md](docs/SECURITY_AND_KEYS.md)** | Details on our private RSA-4096 keyset, Knox mitigation, and stealth stack. |
| 🗺️ **Roadmap** | **[docs/ROADMAP.md](docs/ROADMAP.md)** | Tracked bugs, planned improvements, and upcoming v1.2 milestones. |
| 🔬 **Developer Guides**| **[docs/dev_guides/](docs/dev_guides/)** | Deep dive into Carbon Engine C++20, DAG caching, and graphics architecture. |

---

## 🐛 Bug Reporting & Feedback

Encountered a bug, battery drain, or want to suggest an improvement? We track everything publicly on GitHub:

👉 **[Report an Issue on GitHub](https://github.com/alrigroup/un1ca-carbon/issues)**

*(If you don't have a GitHub account, you can also share your reports and logcats in our [official XDA thread](https://xdaforums.com/t/rom-17-0-oneui-9-0-dm1q-s911b-un1ca-carbon-ix-v1-1-bit-a.4805565/) — our team actively monitors it).*

---

## 🤝 Contributing & Community Help

**UN1CA Carbon is 100% community-driven and non-profit.**

If you are a developer, modder, or Android enthusiast and you like the project, **feel completely free to help out in whatever way you'd like!** 

Whether it's opening a Pull Request with a bug fix, sharing a smali patch, tuning kernel parameters, helping with translations, or testing builds — **any help is always very welcome**. Every contributor will have their name and work **permanently credited** in the project's official README, Release Notes, and XDA thread.

### 💬 Community & Direct Contact
Want to chat, discuss ideas, or reach out directly?
* 🎮 **Discord:** Join the official ALRI GROUP server at **[dsc.gg/alrigroup](https://dsc.gg/alrigroup)**
* ✈️ **Telegram:** Message Alexsander ALRI directly at **[@alexsanderalri](http://t.me/alexsanderalri)**

Feel free to open a PR, join discussions in Issues, or connect with us!

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

* **ALRI Engineering, Calibrations & Carbon Modules (`carbon_ours/`):**  
  Licensed under the **ARGLP — ALRI GROUP LICENSE PERMISSIVE** (see `LICENSE`).
* **UN1CA Core Engine (`core_unica/`):**  
  GNU General Public License v3.0 (GPL-3.0) by Salvo Giangri.
* **Upstream Contributions (`vendors_rezoss/` and `vendors_npl/`):**  
  Retain their respective upstream licenses attributed to @Rezoss-Reza and @cosinemyan.
