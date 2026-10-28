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

## 🔬 Candidate Features & Upstream Inspirations (AstroROM / ProjectArcadeX)
Evaluated and cataloged for implementation and bench-testing in **v1.2**:

### 📷 1. Advanced Camera Unlocks (`camera-feature.xml` & CSC)
* **4K 120 FPS Video Recording:** Activate `BACK_CAMCORDER_RESOLUTION_FEATURE_MAP_3840X2160_120FPS` for Pro Video and Slow Motion modes on Snapdragon 8 Gen 2.
* **50MP Super Resolution:** Enable `8160x6120` full sensor capture matrices in Pro Photo and Super Resolution mode.
* **Continuous Audio Recording:** Enable `CscFeature_Camera_CamcorderDoNotPauseMusic = TRUE` (prevents Spotify, Apple Music, and podcast players from pausing when recording video).
* **Superfine JPEG Quality:** Set `CscFeature_Camera_DefaultQuality = superfine` to minimize Samsung lossy JPEG compression artifacts.
* **In-Call Camera Activation:** Set `CscFeature_Camera_EnableCameraDuringCall = TRUE`.

### 📱 2. High-Value Native CSC Features (`cscfeature.xml`)
* **Samsung Native AppLock:** Inject `applock` into `CscFeature_SmartManager_ConfigSubFeatures` to enable Samsung's biometric app locking out of the box without third-party tools.
* **Data Usage on Quick Panel:** Set `CscFeature_SystemUI_SupportDataUsageViewOnQuickPanel = TRUE` to display real-time network consumption directly under quick settings.
* **Alive Zoom in Gallery:** Enable `CscFeature_Gallery_SupportAliveZoom = TRUE`.
* **Clock Timer Reset:** Set `CscFeature_Clock_SupportTimerResetButton = TRUE`.

### ⚡ 3. UI Snappiness & Window Animations (0.85x Multiplier)
* **Smooth Physics Multiplier:** Patch `WindowManagerService.smali` default window animation scale from stock `1.0f` (`0x3f800000`) to **`0.85f`** (`0x3f59999a`). Delivers instantaneous touch feedback while preserving authentic One UI elastic physics without clipping frames like legacy `0.5x`.

---

## 🔭 Future Milestones (v1.3 & Beyond)

* **Galaxy S23 Family Device Expansion:** Unified device trees for S23+ (`dm2q`) and S23 Ultra (`dm3q`).
* **Differential OTA Updates:** Fast incremental updates without downloading the full 8 GB package.
* **Carbon Engine C++20:** Transitioning internal pipelines to declarative DAG caching for sub-minute builds.

---

## 💡 How to Track & Propose Ideas
All bugs and feature proposals are actively tracked on our official GitHub Issues board:  
👉 **[https://github.com/alrigroup/un1ca-carbon/issues](https://github.com/alrigroup/un1ca-carbon/issues)**
