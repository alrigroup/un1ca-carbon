# 🗺️ UN1CA Carbon — Roadmap & Release Milestones

This document tracks planned milestones, community feature requests, and known issues being addressed across development cycles.

---

## 🎯 Version v1.2 (Active Development)

The primary goal of **v1.2** is addressing community feedback from the initial v1.1 production release, refining battery efficiency, and elevating camera post-processing.

### 🐛 Tracked Bug Fixes (v1.2 Target)
* **[#1] fix(aod):** Resolve Always On Display update failure via Galaxy Store.
* **[#2] fix(settings):** Remove persistent unremovable red notification badge on Display Settings.
* **[#5] fix(ui):** Remove unsupported Privacy Display option from Settings and Quick Settings panel.
* **[#8] fix(systemui):** Fix Power Menu icons styling mismatch (Reboot to Recovery & Flight Mode).
* **[#9] fix(wallpapers):** Restore original stock Galaxy S23 (`dm1q`) wallpapers in Wallpaper & Style.
* **[#10] fix(playstore):** Resolve Google Play System Update disappearing after reboot.
* **[#11] fix(power):** Mitigate background battery drain caused by IMS service alarm loops and sensor polling.

### 🌟 Feature Requests & Enhancements (v1.2 Target)
* **[#3] feat(camera):** Port Galaxy S26 camera post-processing tuning (denoise matrices, chromatic curves).
* **[#4] feat(ai):** Port and integrate Samsung Now Brief (Now Bar) feature.
* **[#6] feat(bootanim):** Add authentic Samsung One UI stock boot animation option to Carbon Settings.
* **[#7] feat(settings):** Enable AI-powered semantic search in Settings app (`SecSettingsIntelligence`).

---

## 🔭 Future Milestones (v1.3 & Beyond)

* **Galaxy S23 Family Device Expansion:** Unified device trees for S23+ (`dm2q`) and S23 Ultra (`dm3q`).
* **Differential OTA Updates:** Fast incremental updates without downloading the full 8 GB package.
* **Carbon Engine C++20:** Transitioning internal pipelines to declarative DAG caching for sub-minute builds.

---

## 💡 How to Track & Propose Ideas
All bugs and feature proposals are actively tracked on our official GitHub Issues board:  
👉 **[https://github.com/alrigroup/un1ca-carbon/issues](https://github.com/alrigroup/un1ca-carbon/issues)**
