SKIPUNZIP=1

LOG_STEP_IN "- Rezoss experimental mods"

# =============================================================================
# Base Overlay
# =============================================================================
ADD_TO_WORK_DIR "$MODPATH" "system" "." 0 0 755 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$MODPATH" "system_ext" "." 0 0 755 "u:object_r:system_file:s0"
LOG "- Adding mountless AOSP zip boot animation support"
ADD_TO_WORK_DIR "$MODPATH/bootanimation_zip" "system" \
    "system/bin/bootanimation_zip" 0 2000 755 "u:object_r:bootanim_exec:s0"
ADD_TO_WORK_DIR "$MODPATH/bootanimation_zip" "system" \
    "system/lib64/libbootanimation.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" \
    "system/etc/default-permissions/default-permissions-com.samsung.android.smartsuggestions.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" \
    "system/etc/permissions/privapp-permissions-com.samsung.android.smartsuggestions.xml" 0 0 644 "u:object_r:system_file:s0"
# Restore the stock S23U One UI 9 packages after debloat and local overlays.
# Samsung Messages already advertises nownudge.inappnudge.revision=1.
LOG "- Using S23U One UI 9 sharing, keyboard and messaging apps"
for f in "app/AllShareAware" "app/HoneyBoard" "priv-app/ShareLive" "priv-app/SamsungMessages"; do
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/$f" 0 0 755 "u:object_r:system_file:s0"
done
# Debloat also removes Messages' permission XMLs; restore them with the APK.
# The privileged allowlist grants MANAGE_USERS for its startup user query.
for f in \
    "default-permissions/default-permissions-com.samsung.android.messaging.xml" \
    "permissions/privapp-permissions-com.samsung.android.messaging.xml"; do
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/etc/$f" 0 0 644 "u:object_r:system_file:s0"
done
LOG "- Patching SmartSuggestions Developer Mode access"
REZOSS_SMARTSUGGESTIONS_APK="$WORK_DIR/system/system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk"
REZOSS_SMARTSUGGESTIONS_TMP="$TMP_DIR/rezoss_smartsuggestions_dev_mode"
REZOSS_SMARTSUGGESTIONS_CERT_PREFIX="aosp"
$ROM_IS_OFFICIAL && REZOSS_SMARTSUGGESTIONS_CERT_PREFIX="unica"
if unzip -l "$REZOSS_SMARTSUGGESTIONS_APK" classes11.dex &>/dev/null; then
EVAL "rm -rf \"$REZOSS_SMARTSUGGESTIONS_TMP\" && mkdir -p \"$REZOSS_SMARTSUGGESTIONS_TMP\""
EVAL "unzip -q -p \"$REZOSS_SMARTSUGGESTIONS_APK\" classes11.dex > \"$REZOSS_SMARTSUGGESTIONS_TMP/classes11.dex\""
EVAL "unzip -q -p \"$REZOSS_SMARTSUGGESTIONS_APK\" classes13.dex > \"$REZOSS_SMARTSUGGESTIONS_TMP/classes13.dex\""
EVAL "unzip -q -p \"$REZOSS_SMARTSUGGESTIONS_APK\" classes14.dex > \"$REZOSS_SMARTSUGGESTIONS_TMP/classes14.dex\""
EVAL "unzip -q -p \"$REZOSS_SMARTSUGGESTIONS_APK\" classes15.dex > \"$REZOSS_SMARTSUGGESTIONS_TMP/classes15.dex\""
EVAL "unzip -q -p \"$REZOSS_SMARTSUGGESTIONS_APK\" AndroidManifest.xml > \"$REZOSS_SMARTSUGGESTIONS_TMP/AndroidManifest.xml\""
EVAL "python3 \"$MODPATH/smartsuggestions/patch_contents_visibility_dex.py\" \"$REZOSS_SMARTSUGGESTIONS_TMP/classes14.dex\""
EVAL "python3 \"$MODPATH/smartsuggestions/patch_now_nudge_dex.py\" \"$REZOSS_SMARTSUGGESTIONS_TMP/classes15.dex\""
EVAL "python3 \"$MODPATH/smartsuggestions/patch_smartsuggestions_dev_mode.py\" \"$REZOSS_SMARTSUGGESTIONS_TMP/classes11.dex\" \"$REZOSS_SMARTSUGGESTIONS_TMP/classes13.dex\" \"$REZOSS_SMARTSUGGESTIONS_TMP/classes15.dex\" \"$REZOSS_SMARTSUGGESTIONS_TMP/AndroidManifest.xml\""
EVAL "cp -a \"$REZOSS_SMARTSUGGESTIONS_APK\" \"$REZOSS_SMARTSUGGESTIONS_TMP/SamsungSmartSuggestions.apk\""
EVAL "cd \"$REZOSS_SMARTSUGGESTIONS_TMP\" && zip -q -0 \"SamsungSmartSuggestions.apk\" classes11.dex classes13.dex classes14.dex classes15.dex AndroidManifest.xml"
EVAL "signapk \"$SRC_DIR/security/${REZOSS_SMARTSUGGESTIONS_CERT_PREFIX}_platform.x509.pem\" \"$SRC_DIR/security/${REZOSS_SMARTSUGGESTIONS_CERT_PREFIX}_platform.pk8\" \"$REZOSS_SMARTSUGGESTIONS_TMP/SamsungSmartSuggestions.apk\" \"$REZOSS_SMARTSUGGESTIONS_TMP/SamsungSmartSuggestions.signed.apk\""
EVAL "mv -f \"$REZOSS_SMARTSUGGESTIONS_TMP/SamsungSmartSuggestions.signed.apk\" \"$REZOSS_SMARTSUGGESTIONS_APK\""
SET_METADATA "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" 0 0 644 "u:object_r:system_file:s0"
EVAL "rm -rf \"$REZOSS_SMARTSUGGESTIONS_TMP\""
fi
LOG "- Patching SmartSuggestions native library extraction"
REZOSS_SMARTSUGGESTIONS_DECODED="$APKTOOL_DIR/system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk"
EVAL "rm -rf \"$REZOSS_SMARTSUGGESTIONS_DECODED\""
DECODE_APK "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk"
EVAL "sed -i 's/android:extractNativeLibs=\"false\"/android:extractNativeLibs=\"true\"/g' \"$REZOSS_SMARTSUGGESTIONS_DECODED/AndroidManifest.xml\""
if ! grep -q 'android:extractNativeLibs="true"' "$REZOSS_SMARTSUGGESTIONS_DECODED/AndroidManifest.xml"; then
    LOGE "Failed to enable native library extraction for SamsungSmartSuggestions.apk"
    return 1
fi
unset REZOSS_SMARTSUGGESTIONS_DECODED
LOG "- Applying SmartSuggestions China compatibility patch"
APPLY_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "$MODPATH/smartsuggestions/SamsungSmartSuggestions.apk/0010-China-SmartSuggestions-compatibility.patch"
APPLY_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "$MODPATH/smartsuggestions/SamsungSmartSuggestions.apk/0011-Enable-Netflix-custom-card-helpers-and-forced-skills.patch"
APPLY_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "$MODPATH/smartsuggestions/SamsungSmartSuggestions.apk/0012-Bind-event-travel-custom-card-sources.patch"
APPLY_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "$MODPATH/smartsuggestions/SamsungSmartSuggestions.apk/0013-Allow-calendar-travel-custom-card-prompts.patch"
APPLY_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "$MODPATH/smartsuggestions/SamsungSmartSuggestions.apk/0025-Remove-Custom-Card-category-limit.patch"
APPLY_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "$MODPATH/smartsuggestions/SamsungSmartSuggestions.apk/0014-Allow-Now-Brief-recall-calendar-reminder-fallback.patch"
APPLY_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "$MODPATH/smartsuggestions/SamsungSmartSuggestions.apk/0015-Force-Now-Brief-non-empty-fallback.patch"
APPLY_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "$MODPATH/smartsuggestions/SamsungSmartSuggestions.apk/0016-Allow-more-Now-Nudge-messenger-packages.patch"
APPLY_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "$MODPATH/smartsuggestions/SamsungSmartSuggestions.apk/0017-Preserve-Now-Nudge-pass-package-message.patch"
APPLY_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "$MODPATH/smartsuggestions/SamsungSmartSuggestions.apk/0018-Route-notification-assistant-requests-to-Now-Nudge.patch"
# Temporarily disabled for CHN SmartSuggestions testing.
# LOG "- Patching SmartSuggestions China custom-card feature gates"
# SMALI_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
#     "smali_classes15/com/samsung/android/smartsuggestions/featureconfig/rune/Rune.smali" "return" \
#     'getSUPPORT_AI_SUGGESTION_CUSTOM_CARD_CHN()Z' \
#     'true' \
#     > /dev/null
# SMALI_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
#     "smali_classes15/com/samsung/android/smartsuggestions/featureconfig/rune/Rune.smali" "return" \
#     'getSUPPORT_AI_SUGGESTION_EDITABLE_CARD_CHN()Z' \
#     'true' \
#     > /dev/null
LOG "- Patching SmartSuggestions Now Nudge experimental runtime gates"
SMALI_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "smali_classes15/com/samsung/android/smartsuggestions/service/screenintelligence/setting/NowNudgesSettingHelper.smali" "return" \
    'isAvailableAccount(Landroid/content/Context;)Z' \
    'true' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "smali_classes15/com/samsung/android/smartsuggestions/service/screenintelligence/setting/NowNudgesSettingHelper.smali" "return" \
    'isOnNowNudgesInApp(Landroid/content/Context;)Z' \
    'true' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "smali_classes15/com/samsung/android/smartsuggestions/service/screenintelligence/setting/NowNudgesSettingHelper.smali" "return" \
    'isNowNudgesSwitchOn(Landroid/content/Context;)Z' \
    'true' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "smali_classes15/com/samsung/android/smartsuggestions/service/autofill/AutofillNudgeProvider.smali" "return" \
    'checkAutofillSupported()Z' \
    'true' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "smali_classes15/com/samsung/android/smartsuggestions/service/autofill/AutofillNudgeProvider.smali" "return" \
    'checkKeyboardLocale()Z' \
    'true' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk" \
    "smali_classes15/com/samsung/android/smartsuggestions/service/policy/AutofillPolicyManager.smali" "return" \
    'isNudgeAllowed(Landroid/content/ComponentName;)Z' \
    'true' \
    > /dev/null
# S23U One UI 9 Messages declares nownudge.inappnudge.revision=1.
# Keep the stock metadata lookup and its missing-package fallback.
unset REZOSS_SMARTSUGGESTIONS_APK REZOSS_SMARTSUGGESTIONS_TMP REZOSS_SMARTSUGGESTIONS_CERT_PREFIX

# =============================================================================
# Device Care / Smart Manager CN
# =============================================================================
DELETE_FROM_WORK_DIR "system" "system/priv-app/SmartManager_v5"
DELETE_FROM_WORK_DIR "system" "system/app/SmartManager_v6_DeviceSecurity"
DELETE_FROM_WORK_DIR "system" "system/etc/permissions/privapp-permissions-com.samsung.android.lool.xml"
DELETE_FROM_WORK_DIR "system" "system/etc/permissions/signature-permissions-com.samsung.android.lool.xml"
DELETE_FROM_WORK_DIR "system" "system/etc/permissions/privapp-permissions-com.samsung.android.sm.devicesecurity_v6.xml"

SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_SECURITY_CONFIG_DEVICEMONITOR_PACKAGE_NAME" "com.samsung.android.sm.devicesecurity.tcm"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_SMARTMANAGER_CONFIG_PACKAGE_NAME" "com.samsung.android.sm_cn"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_SUPPORT_NAL_PRELOADAPP_REGULATION" "TRUE"

# =============================================================================
# Floating Features - Camera
# =============================================================================
# Stock S23U does not define CAMERA_CONFIG_AUTOFRAMING; forcing "uhd" crashes smooth_transition on dm3q.
# SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_CONFIG_AUTOFRAMING" "uhd"
# SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_CONFIG_VENDOR_LIB_INFO" "de_flicker.arcsoft.v1,de_flicker_hdr.arcsoft.v1,food.samsung.v1,face_landmark.arcsoft.v2_1,beauty.samsung.v4,facial_restoration.arcsoft.v1,facial_attribute.samsung.v1,human_tracking_hand.arcsoft.v4,fr_tracking.arcsoft.v1,smart_scan.samsung.v2,aimode.samsung.v2,aimfisp.samsung.v1,ai_clear_zoom.arcsoft.v1,macro_raw_sr.arcsoft.v1,super_resolution_raw.arcsoft.v2,aebhdr.arcsoft.v1,hybridhdr.arcsoft.v1,single_bokeh.samsung.v2,super_night.mpi.v2,swuwdc.arcsoft.v1,event_detection.samsung.v2,selfie_correction.samsung.v1,dual_bokeh.samsung.v1_1,image_codec.samsung.v2,pro_single_rgb.mpi.v1,image_enhance.arcsoft.v1,localtm.samsung.v1_1,stereo_photo.samsung.v1,compressed_raw_decoder.samsung.v1"
# Keep S26U autofocus/fusion/SW-binning paths disabled on dm3q; they crash the S23U vendor camera stack.
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AFSENSITIVITY" "FALSE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AFSMARTTRACKING" "FALSE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AFSPEED" "FALSE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_CINEMATIC_PORTRAITVIDEO" "FALSE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_FUSION_HIGH_RESOLUTION" "FALSE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_HIGH_RESOLUTION_SWBINNING" "FALSE"
# These S26U capture pipelines are not exposed by the stock dm3q camera stack.
# Advertising them makes SamsungCamera submit an unsupported night request and
# triggers CHI recovery (Usecase::DumpSystemEvent) in the camera provider.
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_NIGHT_INTEGRATED_PHOTO_MODE" "FALSE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_SUPER_NIGHT_DRAFT_RAW" "FALSE"
# WARNING: Might Cause Crash
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_VDIS_ON_MOTIONPHOTO" "FALSE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_VIDEO_SOFTENING" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_DUAL_PORTRAITVIDEO" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_EDITABLE_PORTRAITVIDEO" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_PORTRAIT_INTELLIGENT_OPTIMIZATION_AI_ISP" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_SEAMLESS_PORTRAITVIDEO" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AUTO_EXPOSURE_LIMIT" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_MOTIONPHOTO_AUTO_TRIM_MODE" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_MOTIONPHOTO_SOUND_TIMING" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_MOTIONPHOTO_SOUND_TYPE" "TRUE"

# =============================================================================
# Floating Features - Display / Gallery / Media
# =============================================================================
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_SUPPORT_DOZE_AP_SLEEP" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_CFA_CODEC" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_VIDEO_SEARCH" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_VIDEOSERACH" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_LIVEFOCUS_EFFECT_DUAL_BOKEH" "BLUR,EFFECT,BIGBOKEH,PORTRAIT,RELIGHT,REFOCUS,LIGHT360,GENERIC_REFOCUS,GENERIC_REEDIT"
#SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_AI_EXPANSION" "AI_Timelapse,singletake.hidt.support.on,singletake.capture.support.off,singletake.video_res.config.fhd,singletake.video.previous_record"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_REDUCE_FLASH_LIGHT" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_TOUCH_FAST_RESPONSE" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_BRIGHTNESS_ANIMATION" "1"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN" "1"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_HDR2SDR_MAX_8K" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_HIERARCHICAL_B_ENCODING" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_LONGEXPOSURE_EFFECT_10BIT" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_PHOTOHDR" "TRUE"
# WARNING: The S26U FM/unified clipper route previously crashed PhotoEditor_AIFull
# on the S23U SNAP/vendor stack during contour/lasso execution.
# SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_VIDEO_CONFIG_VIDEO_CLIPPING_MODE" "NPU,unifiedclipper,foundational_segmentation"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_VIDEO_CONFIG_VIDEO_CLIPPING_MODE" "NPU"

# =============================================================================
# Floating Features - Galaxy AI / Framework / Search
# =============================================================================
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_ACCESSIBILITY_SUPPORT_AI_CORE_IMAGE_DESCRIPTION" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_CONFIG_WAKEUP_MULTIAGENT_VERSION" "1"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_APPFUNCTION_AGENT_APPLIST" "ai.perplexity.app.android"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_COMPUTER_CONTROL" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_PROVIDE_TSP_RAWDATA" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_SAMSUNG_SEARCH_SEMANTIC_SEARCH_VERSION" "510"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GENAI_CONFIG_FOUNDATION_MODEL" "3B"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GENAI_SUPPORT_TIME_WEATHER_WALLPAPER" "V7"

# =============================================================================
# Helpers
# =============================================================================
_REZOSS_SET_VENDOR_FLOATING_FEATURE_CONFIG()
{
    local CONFIG="$1"
    local VALUE="$2"
    local FILE="$WORK_DIR/vendor/etc/floating_feature.xml"

    if [ ! -f "$FILE" ]; then
        LOGW "File not found: ${FILE//$WORK_DIR/}"
        return 0
    fi

    if grep -q "$CONFIG" "$FILE"; then
        LOG "- Replacing \"$CONFIG\" config with \"$VALUE\" in /vendor/etc/floating_feature.xml"
        sed -i "$(sed -n "/<${CONFIG}>/=" "$FILE") c\ \ \ \ <${CONFIG}>${VALUE}</${CONFIG}>" "$FILE"
    else
        LOG "- Adding \"$CONFIG\" config with \"$VALUE\" in /vendor/etc/floating_feature.xml"
        sed -i "/<\/SecFloatingFeatureSet>/d" "$FILE"
        if ! grep -q "Added by unica/mods/rezoss" "$FILE"; then
            echo "    <!-- Added by unica/mods/rezoss/customize.sh -->" >> "$FILE"
        fi
        echo "    <${CONFIG}>${VALUE}</${CONFIG}>" >> "$FILE"
        echo "</SecFloatingFeatureSet>" >> "$FILE"
    fi
}

_REZOSS_APPEND_UNIQUE_LINE()
{
    local FILE="$1"
    local LINE="$2"

    if ! grep -q -F "$LINE" "$FILE"; then
        echo "$LINE" >> "$FILE"
    fi
}

_REZOSS_ENSURE_FOUNDATIONAL_SEGMENTATION_SYSTEM_CONFIGS()
{
    local PUBLIC_LIBS_FILE="$WORK_DIR/system/system/etc/public.libraries-camera.samsung.txt"
    local IRREMOVABLE_FILE="$WORK_DIR/system/system/etc/irremovable_list.txt"

    if [ -f "$PUBLIC_LIBS_FILE" ]; then
        LOG "- Ensuring foundational segmentation camera public library"
        _REZOSS_APPEND_UNIQUE_LINE "$PUBLIC_LIBS_FILE" "libfoundational_segmentation.camera.samsung.so"
    else
        LOGW "File not found: ${PUBLIC_LIBS_FILE//$WORK_DIR/}"
    fi

    if [ -f "$IRREMOVABLE_FILE" ]; then
        LOG "- Ensuring foundational segmentation irremovable entry"
        _REZOSS_APPEND_UNIQUE_LINE "$IRREMOVABLE_FILE" "/system/lib64/libfoundational_segmentation.camera.samsung.so"
    else
        LOGW "File not found: ${IRREMOVABLE_FILE//$WORK_DIR/}"
    fi
}

_REZOSS_ENSURE_DVS_SYSTEM_CONFIGS()
{
    local PUBLIC_LIBS_FILE="$WORK_DIR/system/system/etc/public.libraries-camera.samsung.txt"
    local IRREMOVABLE_FILE="$WORK_DIR/system/system/etc/irremovable_list.txt"

    if [ -f "$PUBLIC_LIBS_FILE" ]; then
        LOG "- Ensuring DVS camera public library"
        _REZOSS_APPEND_UNIQUE_LINE "$PUBLIC_LIBS_FILE" "libdvs.camera.samsung.so"
    else
        LOGW "File not found: ${PUBLIC_LIBS_FILE//$WORK_DIR/}"
    fi

    if [ -f "$IRREMOVABLE_FILE" ]; then
        LOG "- Ensuring DVS irremovable entry"
        _REZOSS_APPEND_UNIQUE_LINE "$IRREMOVABLE_FILE" "/system/lib64/libdvs.camera.samsung.so"
    else
        LOGW "File not found: ${IRREMOVABLE_FILE//$WORK_DIR/}"
    fi
}

_REZOSS_ENSURE_VENDOR_CONFIG_FILE_CONTEXTS()
{
    local FC_FILE="$WORK_DIR/vendor/etc/selinux/vendor_file_contexts"

    if [ ! -f "$FC_FILE" ]; then
        LOGW "File not found: ${FC_FILE//$WORK_DIR/}"
        return 0
    fi

    LOG "- Ensuring S26U vendor config/model file contexts"
    _REZOSS_APPEND_UNIQUE_LINE "$FC_FILE" "/vendor/etc/saiv/image_understanding/db/doc_rectifier(/.*)? u:object_r:vendor_configs_file:s0"
    _REZOSS_APPEND_UNIQUE_LINE "$FC_FILE" "/vendor/etc/saiv/image_understanding/db/dvs(/.*)? u:object_r:vendor_configs_file:s0"
    _REZOSS_APPEND_UNIQUE_LINE "$FC_FILE" "/vendor/etc/saiv/image_understanding/db/fm(/.*)? u:object_r:vendor_configs_file:s0"
    _REZOSS_APPEND_UNIQUE_LINE "$FC_FILE" "/vendor/etc/saiv/image_understanding/db/ss_magnet(/.*)? u:object_r:vendor_configs_file:s0"
    _REZOSS_APPEND_UNIQUE_LINE "$FC_FILE" "/vendor/etc/midas_enhancedocumentscan(/.*)? u:object_r:vendor_configs_file:s0"
}

_REZOSS_SET_VENDOR_CONFIG_DIR_METADATA()
{
    local ENTRY="$1"
    local BASE="$WORK_DIR/vendor/$ENTRY"
    local FILE
    local REL

    if [ ! -d "$BASE" ]; then
        LOGW "Directory not found: ${BASE//$WORK_DIR/}"
        return 0
    fi

    while IFS= read -r FILE; do
        REL="${FILE#$WORK_DIR/vendor/}"
        if [ -d "$FILE" ]; then
            SET_METADATA "vendor" "$REL" 0 2000 755 "u:object_r:vendor_configs_file:s0"
        else
            SET_METADATA "vendor" "$REL" 0 0 644 "u:object_r:vendor_configs_file:s0"
        fi
    done < <(find "$BASE")
}

_REZOSS_SET_SYSTEM_LIB64_METADATA()
{
    local FILE="$1"
    if [ -e "$WORK_DIR/system/system/lib64/$FILE" ] || [ -e "$WORK_DIR/system/lib64/$FILE" ]; then
        SET_METADATA "system" "system/lib64/$FILE" 0 0 644 "u:object_r:system_lib_file:s0"
    fi
}

_REZOSS_ADD_SYSTEM_LIB64()
{
    local SOURCE="$1"
    local FILE="$2"

    ADD_TO_WORK_DIR "$SOURCE" "system" "system/lib64/$FILE" 0 0 644 "u:object_r:system_lib_file:s0"
    _REZOSS_SET_SYSTEM_LIB64_METADATA "$FILE"
}

_REZOSS_GET_SEPOLICY_API_SUFFIX()
{
    local CIL_FILE="$1"

    if grep -q "(type init_34_0)" "$CIL_FILE"; then
        echo "34_0"
    else
        echo "33_0"
    fi
}

_REZOSS_CIL_HAS_SYMBOL()
{
    local SYMBOL="$1"
    shift

    local FILE
    for FILE in "$@"; do
        [ -f "$FILE" ] || continue
        if grep -q " ${SYMBOL}[ )]" "$FILE" || grep -q "(${SYMBOL}[ )]" "$FILE"; then
            return 0
        fi
    done

    return 1
}

_REZOSS_ENSURE_LOG_VIDEO_FILTER_SELINUX()
{
    local FC_FILE="$WORK_DIR/vendor/etc/selinux/vendor_file_contexts"
    local CIL_FILE="$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"

    if [ -f "$FC_FILE" ]; then
        if ! grep -q -F "/data/vendor/LogVideofilters" "$FC_FILE"; then
            LOG "- Adding LogVideofilters data file context"
            echo "/data/vendor/LogVideofilters(/.*)? u:object_r:LogVideofilters_data_file:s0" >> "$FC_FILE"
        fi
    else
        LOGW "File not found: ${FC_FILE//$WORK_DIR/}"
    fi

    if [ -f "$CIL_FILE" ]; then
        LOG "- Ensuring LogVideofilters SELinux access"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(type LogVideofilters_data_file)"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(roletype object_r LogVideofilters_data_file)"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(typeattributeset file_type (LogVideofilters_data_file))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(typeattributeset data_file_type (LogVideofilters_data_file))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow hal_camera_default LogVideofilters_data_file (dir (ioctl read getattr lock open watch watch_reads search)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow hal_camera_default LogVideofilters_data_file (file (ioctl read getattr lock map open watch watch_reads)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow platform_app_33_0 LogVideofilters_data_file (dir (ioctl read getattr lock open watch watch_reads search)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow platform_app_33_0 LogVideofilters_data_file (file (ioctl read getattr lock map open watch watch_reads)))"
    else
        LOGW "File not found: ${CIL_FILE//$WORK_DIR/}"
    fi
}

_REZOSS_ENSURE_BOOTANIMATION_SELINUX()
{
    local SYSTEM_EXT_SELINUX
    local CIL_FILE

    if $TARGET_OS_BUILD_SYSTEM_EXT_PARTITION; then
        SYSTEM_EXT_SELINUX="$WORK_DIR/system_ext/etc/selinux"
    else
        SYSTEM_EXT_SELINUX="$WORK_DIR/system/system/system_ext/etc/selinux"
    fi

    CIL_FILE="$SYSTEM_EXT_SELINUX/system_ext_sepolicy.cil"

    if [ -f "$CIL_FILE" ]; then
        LOG "- Ensuring mountless AOSP bootanimation SELinux access"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "; Added by unica/mods/rezoss/customize.sh for mountless AOSP zip boot animation"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell self (capability (dac_override dac_read_search)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell bootanim_exec (file (ioctl read getattr lock map open watch watch_reads)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell bootanim_oem_file (file (ioctl read getattr lock map open watch watch_reads)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell system_data_root_file (dir (ioctl read getattr lock open watch watch_reads search)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell adb_data_file (dir (ioctl read getattr lock open watch watch_reads search)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell adb_data_file (file (ioctl read getattr lock map open watch watch_reads)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell bootanim_data_file (dir (ioctl read write create getattr setattr lock rename open watch watch_reads add_name remove_name search rmdir)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell bootanim_data_file (file (ioctl read write create getattr setattr lock map open watch watch_reads rename unlink)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell system_data_file (dir (ioctl read getattr lock open watch watch_reads search)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell system_data_file (file (ioctl read getattr lock map open watch watch_reads)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow bootanim bootanim_data_file (dir (ioctl read getattr lock open watch watch_reads search)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow bootanim bootanim_data_file (file (ioctl read getattr lock map open watch watch_reads)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell ctl_start_prop (property_service (set)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell ctl_start_prop (file (read getattr map open)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell ctl_stop_prop (property_service (set)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell ctl_stop_prop (file (read getattr map open)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell ctl_restart_prop (property_service (set)))"
        _REZOSS_APPEND_UNIQUE_LINE "$CIL_FILE" "(allow sec_system_init_shell ctl_restart_prop (file (read getattr map open)))"
    else
        LOGW "File not found: ${CIL_FILE//$WORK_DIR/}"
    fi
}

_REZOSS_ENSURE_BOOTANIMATION_SELINUX

# =============================================================================
# S26U One UI 9 Quick Share Apple Devices Extension
# =============================================================================
REZOSS_ENABLE_MOSEY_APPLE_SHARING="${REZOSS_ENABLE_MOSEY_APPLE_SHARING:-true}"
if [[ "$REZOSS_ENABLE_MOSEY_APPLE_SHARING" == "true" ]]; then
    LOG "- Adding S26U One UI 9 Mosey system_ext service"
    # S23U One UI 9 already provides mosey_app/server policy and file contexts.
    ADD_TO_WORK_DIR "m3qxxx" "system_ext" "priv-app/MoseyApp" 0 0 755 "u:object_r:system_file:s0"
    ADD_TO_WORK_DIR "m3qxxx" "system_ext" "bin/mosey_server" 0 1000 755 "u:object_r:mosey_server_exec:s0"
    ADD_TO_WORK_DIR "m3qxxx" "system_ext" "lib64/libmosey_daemon_ffi.so" 0 0 644 "u:object_r:system_lib_file:s0"
    for f in "init/mosey.rc" "vintf/manifest/manifest_mosey.xml" \
        "default-permissions/default-permissions-com.google.android.mosey.xml" \
        "permissions/privapp-permissions-com.google.android.mosey.xml" \
        "sysconfig/preinstalled-packages-com.google.android.mosey.xml"; do
        ADD_TO_WORK_DIR "m3qxxx" "system_ext" "etc/$f" 0 0 644 "u:object_r:system_file:s0"
    done
else
    LOG "- Skipping Mosey Quick Share extension; REZOSS_ENABLE_MOSEY_APPLE_SHARING=false"
    DELETE_FROM_WORK_DIR "system" "system/etc/default-permissions/default-permissions-com.google.android.mosey.xml"
    DELETE_FROM_WORK_DIR "system" "system/etc/init/rezoss_mosey_permissions.rc"
    DELETE_FROM_WORK_DIR "system" "system/etc/unica/rezoss_mosey_permissions.sh"
    DELETE_FROM_WORK_DIR "system_ext" "priv-app/MoseyApp"
fi

# =============================================================================
# S26U Prebuilts - Gallery LOG / Camera LOG-LUT / Privacy Display
# =============================================================================
LOG "- Adding S26U Privacy Display, Gallery LOG, Camera LOG/LUT, and Horizon Lock support files"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/cameradata/logCubefiles" 0 0 755 "u:object_r:system_file:s0"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libcontextanalyzer_jni.media.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libmediacontextanalyzer.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libmpp.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libmpp_common.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libmppclient.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libmppfilter.so"

# =============================================================================
# S26U Prebuilts - Video Clipping / Preview Dependencies
# =============================================================================
# Required by S26U Camera LOG/LUT preview.
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libppvdis_core.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libppvdis_interface.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libppvdis_wrapper.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libveframework.videoeditor.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libvideo-highlight-arm64-v8a.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "vendor.samsung.hardware.media.mpp-V5-ndk.so"

# =============================================================================
# S26U Prebuilts - Dual Recording Split View
# =============================================================================
# Disabled after S26U vendor nodes crashed on the dm3q/S23U camera provider stack.
# Keep the existing dm3q/S23U SamsungCamera, recording node, sensor bridge,
# dual calibration bins, and QTI/CHI provider stack active.
# LOG "- Adding S26U Dual Recording Split View vendor nodes"
# ADD_TO_WORK_DIR "m3qxxx" "system" "system/priv-app/SamsungCamera/SamsungCamera.apk" 0 0 644 "u:object_r:system_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "system" "system/priv-app/SamsungCamera/SamsungCamera.apk.prof" 0 0 644 "u:object_r:system_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/libsecsettingsmanager.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/libsensorndkbridge.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/libunidatamanager.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/camera/components/com.samsung.node.uniplugin_recording.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/camera/components/com.samsung.node.uniplugin_meta_surface.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/camera/components/com.samsung.node.uniplugin_record_portrait_depth_extract.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/camera/components/com.samsung.node.uniplugin_record_portrait_render.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/camera/multical_param.bin" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/camera/t2_w_dual_calibration.bin" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/camera/t2_t1_dual_calibration.bin" 0 0 644 "u:object_r:vendor_file:s0"

# =============================================================================
# S26U Prebuilts - Camera Core / Photo Processing Libraries
# =============================================================================
LOG "- Adding S26U camera node libraries for partial vendor-lib feature set"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libAIDeflicker.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libDeflickerHDR.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libsnapshotdebanding.arcsoft.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libStereoSolution.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libSR_StereoCapture.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libfoundational_segmentation.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libdvs.camera.samsung.so"
_REZOSS_ENSURE_FOUNDATIONAL_SEGMENTATION_SYSTEM_CONFIGS
_REZOSS_ENSURE_DVS_SYSTEM_CONFIGS
# S26U replacements previously carried by the rezoss static lib64 overlay.
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "DualOutFocusViewer_B.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libArtifactDetector_v1.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libC2paDps.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libGenSR_saicc_core.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libSR_DynamicRectifier.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libSR_NearDetector.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libStereoWarp.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libTextEnhancementV2.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libVirtualApertureCapture.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libframebooster.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libphotohdr.so"

# =============================================================================
# S26U Prebuilts - PhotoHDR Simba / HEIF Stack
# =============================================================================
# Use the One UI 9 system stack with the stock One UI 9 imagecodec APEX.
LOG "- Adding S26U PhotoHDR Simba/HEIF system stack"
for f in \
    "libsimba.media.samsung.so" \
    "libsimba.decoder.media.samsung.so" \
    "libsimba.cfa.media.samsung.so" \
    "libheifcapture.so" \
    "libheifcapture_jni.media.samsung.so" \
    "libheifcodec_jni.so" \
    "libheifregiondec_jni.so" \
    "libsheif.so" \
    "libsecultrahdr.so" \
    "libultrahdr.so" \
    "libjpegsq.media.samsung.so"; do
    _REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "$f"
done

# =============================================================================
# S26U Prebuilts - Enhanced Document Scan
# =============================================================================
# S26U enhanced document-scan native libs.
# WARNING: Might cause crash
ADD_TO_WORK_DIR "m3qxxx" "system" "system/lib64/libDocColorEnhance.camera.samsung.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/lib64/libDocColorEnhance_Auto.camera.samsung.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/lib64/libDocMagnetEngine.camera.samsung.so" 0 0 644 "u:object_r:system_lib_file:s0"
if [ -e "$WORK_DIR/system/system/lib64/libDocObjectRemovalV2.camera.samsung.so" ] || \
        [ -L "$WORK_DIR/system/system/lib64/libDocObjectRemovalV2.camera.samsung.so" ]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/libDocObjectRemovalV2.camera.samsung.so"
fi
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libDocScannerFilterV2.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libDocShadowRemoval.camera.samsung.so"
_REZOSS_ADD_SYSTEM_LIB64 "m3qxxx" "libMoireFilterV2.camera.samsung.so"
for f in \
    "libcontextanalyzer_jni.media.samsung.so" \
    "libmediacontextanalyzer.so" \
    "libmpp.so" \
    "libmpp_common.so" \
    "libmppclient.so" \
    "libmppfilter.so" \
    "libppvdis_core.so" \
    "libppvdis_interface.so" \
    "libppvdis_wrapper.so" \
    "libveframework.videoeditor.samsung.so" \
    "libvideo-highlight-arm64-v8a.so" \
    "vendor.samsung.hardware.media.mpp-V5-ndk.so" \
    "libAIDeflicker.camera.samsung.so" \
    "DualOutFocusViewer_B.so" \
    "libArtifactDetector_v1.camera.samsung.so" \
    "libC2paDps.camera.samsung.so" \
    "libDeflickerHDR.camera.samsung.so" \
    "libDocColorEnhance.camera.samsung.so" \
    "libDocColorEnhance_Auto.camera.samsung.so" \
    "libDocMagnetEngine.camera.samsung.so" \
    "libDocScannerFilterV2.camera.samsung.so" \
    "libDocShadowRemoval.camera.samsung.so" \
    "libdvs.camera.samsung.so" \
    "libfoundational_segmentation.camera.samsung.so" \
    "libGenSR_saicc_core.camera.samsung.so" \
    "libMoireFilterV2.camera.samsung.so" \
    "libSR_DynamicRectifier.camera.samsung.so" \
    "libSR_NearDetector.camera.samsung.so" \
    "libsnapshotdebanding.arcsoft.so" \
    "libStereoSolution.camera.samsung.so" \
    "libSR_StereoCapture.camera.samsung.so" \
    "libStereoWarp.camera.samsung.so" \
    "libTextEnhancementV2.camera.samsung.so" \
    "libVirtualApertureCapture.camera.samsung.so" \
    "libframebooster.so" \
    "libphotohdr.so" \
    "libsamsungSoundbooster_plus_legacy.so" \
    "libsoundboostereq_legacy.so"; do
    _REZOSS_SET_SYSTEM_LIB64_METADATA "$f"
done

# =============================================================================
# S26U Prebuilts - Video Clipping / Document Scan Models
# =============================================================================
LOG "- Adding S26U video clipping and document-scan model files"
_REZOSS_ENSURE_VENDOR_CONFIG_FILE_CONTEXTS
ADD_TO_WORK_DIR "m3qxxx" "vendor" "etc/saiv/image_understanding/db/fm" 0 2000 755 "u:object_r:vendor_configs_file:s0"
ADD_TO_WORK_DIR "m3qxxx" "vendor" "etc/saiv/image_understanding/db/dvs" 0 2000 755 "u:object_r:vendor_configs_file:s0"
# S26U enhanced document-scan configs/models.
# WARNING: Might cause crash.
ADD_TO_WORK_DIR "m3qxxx" "vendor" "etc/saiv/image_understanding/db/doc_rectifier" 0 2000 755 "u:object_r:vendor_configs_file:s0"
ADD_TO_WORK_DIR "m3qxxx" "vendor" "etc/saiv/image_understanding/db/ss_magnet" 0 2000 755 "u:object_r:vendor_configs_file:s0"
ADD_TO_WORK_DIR "m3qxxx" "vendor" "etc/midas_enhancedocumentscan" 0 2000 755 "u:object_r:vendor_configs_file:s0"
for f in \
    "etc/saiv/image_understanding/db/dvs" \
    "etc/saiv/image_understanding/db/fm"; do
    _REZOSS_SET_VENDOR_CONFIG_DIR_METADATA "$f"
done

# Do not install the S26U compressed-RAW stack on dm3q. These libraries execute
# inside the S23U camera-provider process and can stall its Night capture graph.
# Keep the matching libraries from the untouched target firmware instead.

# =============================================================================
# S26U Prebuilts - Video Editor / LOG Transitive Dependencies
# =============================================================================
# Transitive dependencies of the S26U video editor / LOG correction stack.
ADD_TO_WORK_DIR "m3qxxx" "system" "system/lib64/libmultisourceseparator.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/lib64/libsbs.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/lib64/libtensorflowlite_gpu_delegate.so" 0 0 644 "u:object_r:system_lib_file:s0"
for f in \
    "libmultisourceseparator.so" \
    "libsbs.so" \
    "libtensorflowlite_gpu_delegate.so"; do
    _REZOSS_SET_SYSTEM_LIB64_METADATA "$f"
done

# =============================================================================
# Disabled Experiments - Camera Vendor Stack
# =============================================================================
# Rezoss S26U Horizon Lock vendor VDIS experiment.
# WARNING: Disabled after confirmed camera crash.
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/camera/components/com.samsung.node.uniplugin_vdis.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/libvdis_interface.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/libvdis_core.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/libsecsettingsmanager.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/libIMUSensor.so" 0 0 644 "u:object_r:vendor_file:s0"

# Optional deeper S26U sensor/OIS test.
# WARNING: Disabled after crash.
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/libsensorndkbridge.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/libprotobuf-cpp-lite-21.12.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/liboischannel.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/libois_channel_stub.so" 0 0 644 "u:object_r:vendor_file:s0"
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/libois_channel_factory_test_stub.so" 0 0 644 "u:object_r:vendor_file:s0"

# =============================================================================
# S26U Prebuilts - PhotoHDR Vendor Encoder Plugin
# =============================================================================
# Keep dm3q UniHAL support libraries from the S23U vendor stack. Importing the
# S26U copies here changes shared dependencies used by object-tracking AF.
LOG "- Adding S26U PhotoHDR vendor encoder plugin"
for f in \
    "libSecPhotoHdrEncoder.uniplugin@1.0.so"; do
    ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/$f" 0 0 644 "u:object_r:vendor_file:s0"
done

# =============================================================================
# Vendor Floating Feature Mirror / SELinux Fixups
# =============================================================================
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_PRIVACY_DISPLAY" "1"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_SUPPORT_LOG_CORRECT_COLOR" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_CONFIG_LOG_VIDEO" "V1.0"
_REZOSS_SET_VENDOR_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_PRIVACY_DISPLAY" "1"
_REZOSS_SET_VENDOR_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_CONFIG_VENDOR_LIB_INFO" "single_bokeh.samsung.v2,smart_scan.samsung.v2,beauty.samsung.v4"
_REZOSS_SET_VENDOR_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_FUSION_HIGH_RESOLUTION" "FALSE"
_REZOSS_SET_VENDOR_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_HIGH_RESOLUTION_SWBINNING" "FALSE"
_REZOSS_ENSURE_LOG_VIDEO_FILTER_SELINUX

unset -f _REZOSS_SET_VENDOR_FLOATING_FEATURE_CONFIG _REZOSS_APPEND_UNIQUE_LINE
unset -f _REZOSS_ENSURE_FOUNDATIONAL_SEGMENTATION_SYSTEM_CONFIGS _REZOSS_ENSURE_DVS_SYSTEM_CONFIGS
unset -f _REZOSS_ENSURE_MOSEY_VENDOR_SELINUX _REZOSS_GET_MOSEY_APP_DOMAIN
unset -f _REZOSS_DROP_MOSEY_APP_VENDOR_RULES _REZOSS_CIL_HAS_SYMBOL _REZOSS_GET_SEPOLICY_API_SUFFIX
unset -f _REZOSS_ENSURE_LOG_VIDEO_FILTER_SELINUX _REZOSS_ENSURE_BOOTANIMATION_SELINUX


# =============================================================================
# Build Display Branding
# =============================================================================
PDA_SUFFIX="$(GET_PROP "system" "ro.build.PDA")"
PDA_SUFFIX="${PDA_SUFFIX: -4}"
NOW_BUILD="UN1CA Carbon IX v1.1 (${PDA_SUFFIX})"
SET_PROP "system" "ro.build.display.id" "${NOW_BUILD}"
SET_PROP "product" "ro.build.display.id" "${NOW_BUILD}"

# =============================================================================
# Local System App Overlays
# =============================================================================
# The legacy SamsungSans overlay bundles over 1k asset fonts. One UI 9 Studio
# loads installed decoration fonts into a 512 MB heap and can OOM on this APK.
# Keep the stock Monotype preload set and expose SamsungSans only as a source
# bank for the UN1CA Font Selector.
DELETE_FROM_WORK_DIR "system" "system/app/SamsungSans"
SAMSUNGSANS_SOURCE_APK="$SRC_DIR/prebuilts/samsung/dm3qxxx/system/app/SamsungSans/SamsungSans.apk"
SAMSUNGSANS_BANK_APK="$WORK_DIR/system/system/etc/unica/font_selector/SamsungSans.apk"
if [ -f "$SAMSUNGSANS_SOURCE_APK" ] || [ -f "$SAMSUNGSANS_SOURCE_APK.00" ]; then
    LOG "- Adding SamsungSans source bank for UN1CA Font Selector"
    EVAL "mkdir -p \"$(dirname "$SAMSUNGSANS_BANK_APK")\""
    if [ -f "$SAMSUNGSANS_SOURCE_APK" ]; then
        EVAL "cp -a \"$SAMSUNGSANS_SOURCE_APK\" \"$SAMSUNGSANS_BANK_APK\""
    else
        EVAL "cat \"$SAMSUNGSANS_SOURCE_APK.\"[0-9][0-9] > \"$SAMSUNGSANS_BANK_APK\""
    fi
    SET_METADATA "system" "system/etc/unica" 0 0 755 "u:object_r:system_file:s0"
    SET_METADATA "system" "system/etc/unica/font_selector" 0 0 755 "u:object_r:system_file:s0"
    SET_METADATA "system" "system/etc/unica/font_selector/SamsungSans.apk" 0 0 644 "u:object_r:system_file:s0"
else
    LOGW "SamsungSans source bank not found; UN1CA Font Selector will show a missing-source message"
fi
unset SAMSUNGSANS_SOURCE_APK SAMSUNGSANS_BANK_APK
ADD_TO_WORK_DIR "dm3qxxx" "system" "system/app/VisionModel-Stub/VisionModel-Stub.apk" 0 0 644 "u:object_r:system_file:s0"

# =============================================================================
# Ambient Weather Wallpaper / VisualCloudCore Patches
# =============================================================================
LOG "- Patch stock DressRoom Ambient Weather feature gate"
APPLY_PATCH "system" "system/priv-app/DressRoom/DressRoom.apk" \
    "$MODPATH/dressroom/DressRoom.apk/0001-Bypass-AICore-weather-feature-check.patch"

LOG "- Patch DressRoom UN1CA lockscreen font picker integration"
if [ -f "$APKTOOL_DIR/system/priv-app/DressRoom/DressRoom.apk/apktool.yml" ]; then
    REZOSS_DRESSROOM_PATCH=$(mktemp /tmp/rezoss-dressroom-fonts.XXXXXX.patch 2>/dev/null || echo "")
    if [ -n "$REZOSS_DRESSROOM_PATCH" ]; then
        if python3 "$MODPATH/dressroom/resolve_font_patch.py" \
            "$APKTOOL_DIR/system/priv-app/DressRoom/DressRoom.apk" \
            "$MODPATH/dressroom/DressRoom.apk/0002-Expose-UN1CA-selected-fonts-to-lockscreen-picker.patch" \
            > "$REZOSS_DRESSROOM_PATCH" 2>/dev/null; then
            APPLY_PATCH "system" "system/priv-app/DressRoom/DressRoom.apk" "$REZOSS_DRESSROOM_PATCH" || true
        else
            LOGW "DressRoom font patch could not be resolved on dm1q, skipping..."
        fi
        rm -f -- "$REZOSS_DRESSROOM_PATCH"
        unset REZOSS_DRESSROOM_PATCH
    fi
fi

# Use stock S23 AODService or patch if already decoded
LOG "- Patch AODService UN1CA clock font list integration"
APPLY_PATCH "system" "system/priv-app/AODService_v80/AODService_v80.apk" \
    "$MODPATH/aodservice/AODService_v80.apk/0001-Expose-UN1CA-Font-Selector-fonts-to-clock-picker.patch" || true

LOG "- Patch AODService stretch clock font type sync"
APPLY_PATCH "system" "system/priv-app/AODService_v80/AODService_v80.apk" \
    "$MODPATH/aodservice/AODService_v80.apk/0002-Mirror-stretch-clock-font-type-to-AOD.patch"

LOG "- Patch AODService stretch clock font type startup backfill"
APPLY_PATCH "system" "system/priv-app/AODService_v80/AODService_v80.apk" \
    "$MODPATH/aodservice/AODService_v80.apk/0003-Backfill-AOD-stretch-font-type-on-startup.patch"

LOG "- Patch AODService stretch clock font render normalization"
APPLY_PATCH "system" "system/priv-app/AODService_v80/AODService_v80.apk" \
    "$MODPATH/aodservice/AODService_v80.apk/0004-Normalize-stretch-font-data-before-AOD-render.patch"

LOG "- Patch AODService AOD stretch font heights"
APPLY_PATCH "system" "system/priv-app/AODService_v80/AODService_v80.apk" \
    "$MODPATH/aodservice/AODService_v80.apk/0005-Preserve-AOD-stretch-font-heights.patch"

LOG "- Patch AODService AOD stretch renderer gate"
APPLY_PATCH "system" "system/priv-app/AODService_v80/AODService_v80.apk" \
    "$MODPATH/aodservice/AODService_v80.apk/0006-Allow-AOD-stretch-render-when-font-heights-exist.patch"

# Bump AODService versionCode to prevent Galaxy Store update mismatch & install failure (Resolves Issue #1)
AOD_DIR="$APKTOOL_DIR/system/priv-app/AODService_v80/AODService_v80.apk"
if [ -d "$AOD_DIR" ]; then
    LOG "- Bumping AODService versionCode to prevent Galaxy Store update prompt"
    if [ -f "$AOD_DIR/apktool.yml" ]; then
        sed -i -E "s/(versionCode:[[:space:]]*['\"]?)[0-9]+(['\"]?)/\1999999999\2/g" "$AOD_DIR/apktool.yml"
        sed -i -E "s/(versionName:[[:space:]]*['\"]?)[^'\"]+(['\"]?)/\19.9.99\2/g" "$AOD_DIR/apktool.yml"
    fi
    if [ -f "$AOD_DIR/AndroidManifest.xml" ]; then
        sed -i -E 's/android:versionCode="[0-9]+"/android:versionCode="999999999"/g' "$AOD_DIR/AndroidManifest.xml"
        sed -i -E 's/android:versionName="[^"]+"/android:versionName="9.9.99"/g' "$AOD_DIR/AndroidManifest.xml"
    fi
fi
unset AOD_DIR

LOG "- Patch VisualCloudCore Galaxy Store model check"
APPLY_PATCH "system" "system/app/VisualCloudCore/VisualCloudCore.apk" \
    "$MODPATH/visualcloudcore/VisualCloudCore.apk/0001-Use-S25-Ultra-model-for-stub-update-check.patch"

LOG "- Patch product framework overlay doze auto-brightness"
if [[ "$TARGET_CODENAME" == "dm3q" ]]; then
    if [ -f "$WORK_DIR/product/overlay/framework-res__dm3qxxx__auto_generated_rro_product.apk" ] && [ -d "$MODPATH/rro/framework-res__dm3qxxx__auto_generated_rro_product.apk" ]; then
        APPLY_PATCH "product" "overlay/framework-res__dm3qxxx__auto_generated_rro_product.apk" \
            "$MODPATH/rro/framework-res__dm3qxxx__auto_generated_rro_product.apk/0001-Add-doze-auto-brightness-arrays.patch"
    fi
else
    LOG "- Skipping doze auto-brightness patch for $TARGET_CODENAME (protects non-dm3q AMOLED display from hardware damage)"
fi

# =============================================================================
# Notification Highlights / Galaxy AI Stack
# =============================================================================
# S26U Notification highlights requirements: expose the Galaxy AI common-AI gate, keep LLM/offline model metadata enabled for the backend, ensure the offline language model stub is present, remove the extra SecSettings LLM-version UI gate, allow dmxq devices in NmRune, and enable priority/summary defaults.
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_CONFIG_AI_VERSION" "20263"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_NOW_NUDGE_VERSION" "2"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GENAI_CONFIG_LLM_VERSION" "0.81"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GENAI_SUPPORT_OFFLINE_LANGUAGEMODEL" "TRUE"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/app/SketchBook/SketchBook.apk" 0 0 644 "u:object_r:system_file:s0"
LOG "- Overlay S26U Notification highlights AI APKs"
LOG "- Adding S26U One UI 9 Samsung Intelligence Voice Service"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/priv-app/SamsungIntelliVoiceServices/SamsungIntelliVoiceServices.apk" 0 0 644 "u:object_r:system_file:s0"
SET_METADATA "system" "system/priv-app/SamsungIntelliVoiceServices" 0 0 755 "u:object_r:system_file:s0"
SET_METADATA "system" "system/priv-app/SamsungIntelliVoiceServices/SamsungIntelliVoiceServices.apk" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/priv-app/SamsungAiCore/SamsungAiCore.apk" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/etc/permissions/privapp-permissions-com.samsung.android.aicore.xml" 0 0 644 "u:object_r:system_file:s0"
DELETE_FROM_WORK_DIR "system" "system/app/AIOSKernelService"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/priv-app/AIOSKernelService/AIOSKernelService.apk" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/etc/permissions/privapp-permissions-com.samsung.android.aioskernelservice.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "pa2qxxx" "system" "system/etc/sysconfig/aioskernelservice.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/etc/permissions/signature-permissions-com.samsung.android.offline.languagemodel.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "m3qxxx" "system" "system/priv-app/OfflineLanguageModel_stub/OfflineLanguageModel_stub.apk" 0 0 644 "u:object_r:system_file:s0"

LOG "- Adding S26U NMT languagepack preload metadata"
S26U_NMT_TARGET_PRELOAD="$WORK_DIR/system/system/etc/removable_preload.txt"
if [ ! -f "$S26U_NMT_TARGET_PRELOAD" ]; then
    LOGE "File not found: ${S26U_NMT_TARGET_PRELOAD//$SRC_DIR\//}"
    return 1
fi
ADD_S26U_NMT_PRELOAD()
{
    local NMT_LANG="$1"
    local PKG="com.samsung.android.nmt.apps.t2t.languagepack.$NMT_LANG"
    local PRELOAD_BLOCK="$MODPATH/nmt-preload/$NMT_LANG.txt"

    if grep -Fq "name='$PKG'" "$S26U_NMT_TARGET_PRELOAD"; then
        return 0
    fi

    if [ ! -s "$PRELOAD_BLOCK" ]; then
        LOGE "Missing S26U preload metadata for $PKG"
        return 1
    fi

    LOG "- Adding $PKG to removable_preload.txt"
    {
        echo ""
        cat "$PRELOAD_BLOCK"
    } >> "$S26U_NMT_TARGET_PRELOAD"
}
for NMT_LANG in \
    enar \
    enesus \
    enfil \
    enid \
    enko \
    ennl \
    enpt \
    enro \
    enru \
    ensv \
    entr \
    enzh; do
    ADD_S26U_NMT_PRELOAD "$NMT_LANG" || return 1
done
unset -f ADD_S26U_NMT_PRELOAD
unset NMT_LANG S26U_NMT_TARGET_PRELOAD
#ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/vendor.qti.hardware.dsp-V1-ndk.so" 0 0 644 "u:object_r:vendor_file:s0"
# Causing bootloop
# ADD_TO_WORK_DIR "m3qxxx" "vendor" "lib64/android.hardware.common-V2-ndk.so" 0 0 644 "u:object_r:vendor_file:s0"
# DOWNLOAD_FILE "$(GET_GALAXY_STORE_DOWNLOAD_URL "com.samsung.android.aicore")" \
    # "$WORK_DIR/system/system/priv-app/SamsungAiCore/SamsungAiCore.apk"

REZOSS_SIVS_MODEL_PATCHED_FILE="$APKTOOL_DIR/system/priv-app/SamsungIntelliVoiceServices/SamsungIntelliVoiceServices.apk/smali/com/samsung/android/intellivoiceservice/common/connection/server/LlmClientInterceptor.smali"
REZOSS_SIVS_MODEL_PATCH_MARKER="$APKTOOL_DIR/system/priv-app/SamsungIntelliVoiceServices/SamsungIntelliVoiceServices.apk/.rezoss_s26u_device_model_patch_applied"
if [ -f "$REZOSS_SIVS_MODEL_PATCHED_FILE" ] && grep -qF 'const-string v4, "SM-S948B"' "$REZOSS_SIVS_MODEL_PATCHED_FILE"; then
    touch "$REZOSS_SIVS_MODEL_PATCH_MARKER"
fi
if [ ! -f "$REZOSS_SIVS_MODEL_PATCH_MARKER" ]; then
    LOG "- Patch SamsungIntelliVoiceServices SCS device-model header to SM-S948B"
    APPLY_PATCH "system" "system/priv-app/SamsungIntelliVoiceServices/SamsungIntelliVoiceServices.apk" \
        "$MODPATH/sivs/SamsungIntelliVoiceServices.apk/0001-Use-S26U-device-model-for-SCS-requests.patch"
    touch "$REZOSS_SIVS_MODEL_PATCH_MARKER"
fi
unset REZOSS_SIVS_MODEL_PATCHED_FILE REZOSS_SIVS_MODEL_PATCH_MARKER

if [ -f "$WORK_DIR/system/system/priv-app/SamsungAiCore/SamsungAiCore.apk" ]; then
    LOG "- Patch SamsungAiCore Vision Model device mapping"
    APPLY_PATCH "system" "system/priv-app/SamsungAiCore/SamsungAiCore.apk" \
        "$MODPATH/aicore/SamsungAiCore.apk/0001-Map-dm-series-to-m3q-for-vision-model.patch" || true

    LOG "- Experimentally patch SamsungAiCore SM8550/V73 QNN profile"
    APPLY_PATCH "system" "system/priv-app/SamsungAiCore/SamsungAiCore.apk" \
        "$MODPATH/aicore/SamsungAiCore.apk/0002-Experiment-enable-SM8550-V73-QNN-profile.patch" || true
fi
# Experimental: replace the S26U V81 HTP binaries inside SamsungAiCore.apk with
# S23U Hexagon V73 binaries and patch AiCore's own QNN wrapper crash paths.
local AICORE_DECODED_APK="$APKTOOL_DIR/system/priv-app/SamsungAiCore/SamsungAiCore.apk"
local AICORE_DECODED_LIB="$AICORE_DECODED_APK/lib/arm64-v8a"
local AICORE_DECODED_SSGEN_LIB="$AICORE_DECODED_APK/assets/ssgen/libs"
local AICORE_SNAP_QNN_LIB="$AICORE_DECODED_LIB/libsnap_qnn.so"
local AICORE_SNAP_QNN_PATCHED_LIB="$TMP_DIR/aicore_libsnap_qnn.so"
local AICORE_S23U_FW_DIR="$FW_DIR/SM-S918B_EUX"
local AICORE_QNN_MISSING=0
if [ ! -d "$AICORE_DECODED_LIB" ] || [ ! -d "$AICORE_DECODED_SSGEN_LIB" ]; then
    LOGW "SamsungAiCore.apk decoded QNN directories are missing, skipping QNN patch"
    return 0
fi
if [ ! -f "$AICORE_SNAP_QNN_LIB" ]; then
    LOGE "SamsungAiCore.apk libsnap_qnn.so is missing"
    return 1
fi
for f in \
    "$AICORE_S23U_FW_DIR/vendor/lib64/snap/libQnnHtp.so" \
    "$AICORE_S23U_FW_DIR/vendor/lib64/snap/libQnnSystem.so" \
    "$AICORE_S23U_FW_DIR/vendor/lib64/snap/libQnnHtpV73Stub.so" \
    "$AICORE_S23U_FW_DIR/vendor/lib/rfsa/adsp/snap/libQnnHtpV73Skel.so"; do
    if [ ! -f "$f" ]; then
        LOGE "File not found: ${f//$SRC_DIR\//}"
        AICORE_QNN_MISSING=1
    fi
done
if [ "$AICORE_QNN_MISSING" != "0" ]; then
    return 1
fi
LOG "- Replacing SamsungAiCore.apk QNN HTP V81 binaries with S23U Hexagon V73 binaries"
cp -f "$AICORE_S23U_FW_DIR/vendor/lib64/snap/libQnnHtp.so" "$AICORE_DECODED_LIB/libQnnHtp.so"
cp -f "$AICORE_S23U_FW_DIR/vendor/lib64/snap/libQnnSystem.so" "$AICORE_DECODED_LIB/libQnnSystem.so"
cp -f "$AICORE_S23U_FW_DIR/vendor/lib64/snap/libQnnHtpV73Stub.so" "$AICORE_DECODED_LIB/libQnnHtpV73Stub.so"
cp -f "$AICORE_S23U_FW_DIR/vendor/lib64/snap/libQnnHtpV73Stub.so" "$AICORE_DECODED_LIB/libQnnHtpV81Stub.so"
cp -f "$AICORE_S23U_FW_DIR/vendor/lib/rfsa/adsp/snap/libQnnHtpV73Skel.so" "$AICORE_DECODED_SSGEN_LIB/libQnnHtpV73Skel.so"
cp -f "$AICORE_S23U_FW_DIR/vendor/lib/rfsa/adsp/snap/libQnnHtpV73Skel.so" "$AICORE_DECODED_SSGEN_LIB/libQnnHtpV81Skel.so"
if [ -f "$AICORE_S23U_FW_DIR/vendor/lib64/libqnnengine.so" ]; then
    cp -f "$AICORE_S23U_FW_DIR/vendor/lib64/libqnnengine.so" "$AICORE_DECODED_LIB/libqnnengine.so"
fi
LOG "- Patching SamsungAiCore QNN wrapper for SM8550/V73 experiment"
EVAL "python3 \"$MODPATH/aicore/patch_samsung_aicore_qnn_v73_experiment.py\" \"$AICORE_SNAP_QNN_LIB\" \"$AICORE_SNAP_QNN_PATCHED_LIB\""
EVAL "mv -f \"$AICORE_SNAP_QNN_PATCHED_LIB\" \"$AICORE_SNAP_QNN_LIB\""
unset AICORE_DECODED_APK AICORE_DECODED_LIB AICORE_DECODED_SSGEN_LIB AICORE_SNAP_QNN_LIB AICORE_SNAP_QNN_PATCHED_LIB AICORE_S23U_FW_DIR AICORE_QNN_MISSING

if [ -f "$WORK_DIR/system/system/priv-app/AIOSKernelService/AIOSKernelService.apk" ]; then
    LOG "- Patching AIOSKernelService service config for SM8550"
    APPLY_PATCH "system" "system/priv-app/AIOSKernelService/AIOSKernelService.apk" \
        "$MODPATH/aioskernel/AIOSKernelService.apk/0001-Allow-SM8550-service-config.patch" || true
    LOG "- Patching AIOSKernelService QNN Skel name for Hexagon V73"
    APPLY_PATCH "system" "system/priv-app/AIOSKernelService/AIOSKernelService.apk" \
        "$MODPATH/aioskernel/AIOSKernelService.apk/0002-Use-Hexagon-V73-QNN-skel.patch" || true
    LOG "- Spoofing AIOSKernelService build flavor for SM8550"
    APPLY_PATCH "system" "system/priv-app/AIOSKernelService/AIOSKernelService.apk" \
        "$MODPATH/aioskernel/AIOSKernelService.apk/0003-Spoof-SM8550-build-flavor.patch" || true
    LOG "- Refusing AIOSKernelService LLM/LLMV before QNN execution on SM8550"
    APPLY_PATCH "system" "system/priv-app/AIOSKernelService/AIOSKernelService.apk" \
        "$MODPATH/aioskernel/AIOSKernelService.apk/0004-Refuse-LLM-LLMV-before-QNN-execution.patch" || true
fi
# Replace the S26U V81 HTP binaries inside AIOSKernelService.apk with the S23U Hexagon V73 pair.
local AIOS_DECODED_APK="$APKTOOL_DIR/system/priv-app/AIOSKernelService/AIOSKernelService.apk"
local AIOS_DECODED_LIB="$AIOS_DECODED_APK/lib/arm64-v8a"
local AIOS_DECODED_SSGEN_LIB="$AIOS_DECODED_APK/assets/ssgen/libs"
local AIOS_SSN_LIB="$AIOS_DECODED_LIB/libssneural_vndk.so"
local AIOS_SSN_PATCHED_LIB="$TMP_DIR/aios_libssneural_vndk.so"
local AIOS_SNAP_QNN_LIB="$AIOS_DECODED_LIB/libsnap_qnn.so"
local AIOS_SNAP_QNN_PATCHED_LIB="$TMP_DIR/aios_libsnap_qnn.so"
local S23U_FW_DIR="$FW_DIR/SM-S918B_EUX"
local AIOS_QNN_MISSING=0
if [ ! -d "$AIOS_DECODED_LIB" ] || [ ! -d "$AIOS_DECODED_SSGEN_LIB" ]; then
    LOGW "AIOSKernelService.apk decoded QNN directories are missing, skipping QNN patch"
    return 0
fi
if [ ! -f "$AIOS_SSN_LIB" ]; then
    LOGE "AIOSKernelService.apk libssneural_vndk.so is missing"
    return 1
fi
if [ ! -f "$AIOS_SNAP_QNN_LIB" ]; then
    LOGE "AIOSKernelService.apk libsnap_qnn.so is missing"
    return 1
fi
for f in \
    "$S23U_FW_DIR/vendor/lib64/snap/libQnnHtp.so" \
    "$S23U_FW_DIR/vendor/lib64/snap/libQnnSystem.so" \
    "$S23U_FW_DIR/vendor/lib64/snap/libQnnHtpV73Stub.so" \
    "$S23U_FW_DIR/vendor/lib/rfsa/adsp/snap/libQnnHtpV73Skel.so"; do
    if [ ! -f "$f" ]; then
        LOGE "File not found: ${f//$SRC_DIR\//}"
        AIOS_QNN_MISSING=1
    fi
done
if [ "$AIOS_QNN_MISSING" != "0" ]; then
    return 1
fi
LOG "- Replacing AIOSKernelService.apk QNN HTP V81 binaries with S23U Hexagon V73 binaries"
cp -f "$S23U_FW_DIR/vendor/lib64/snap/libQnnHtp.so" "$AIOS_DECODED_LIB/libQnnHtp.so"
cp -f "$S23U_FW_DIR/vendor/lib64/snap/libQnnSystem.so" "$AIOS_DECODED_LIB/libQnnSystem.so"
cp -f "$S23U_FW_DIR/vendor/lib64/snap/libQnnHtpV73Stub.so" "$AIOS_DECODED_LIB/libQnnHtpV73Stub.so"
cp -f "$S23U_FW_DIR/vendor/lib64/snap/libQnnHtpV73Stub.so" "$AIOS_DECODED_LIB/libQnnHtpV81Stub.so"
cp -f "$S23U_FW_DIR/vendor/lib/rfsa/adsp/snap/libQnnHtpV73Skel.so" "$AIOS_DECODED_SSGEN_LIB/libQnnHtpV73Skel.so"
cp -f "$S23U_FW_DIR/vendor/lib/rfsa/adsp/snap/libQnnHtpV73Skel.so" "$AIOS_DECODED_SSGEN_LIB/libQnnHtpV81Skel.so"
if [ -f "$S23U_FW_DIR/vendor/lib64/libqnnengine.so" ]; then
    cp -f "$S23U_FW_DIR/vendor/lib64/libqnnengine.so" "$AIOS_DECODED_LIB/libqnnengine.so"
fi
LOG "- Patching AIOSKernelService native SSNeural SM8550 support gate"
EVAL "python3 \"$MODPATH/aioskernel/patch_sm8550_chipset.py\" \"$AIOS_SSN_LIB\" \"$AIOS_SSN_PATCHED_LIB\""
EVAL "mv -f \"$AIOS_SSN_PATCHED_LIB\" \"$AIOS_SSN_LIB\""
LOG "- Patching AIOSKernelService QNN logging null guard"
EVAL "python3 \"$MODPATH/aioskernel/patch_qnn_logging_nullguard.py\" \"$AIOS_SNAP_QNN_LIB\" \"$AIOS_SNAP_QNN_PATCHED_LIB\""
EVAL "mv -f \"$AIOS_SNAP_QNN_PATCHED_LIB\" \"$AIOS_SNAP_QNN_LIB\""
LOG "- Patching AIOSKernelService QNN backend V73 fallback"
EVAL "python3 \"$MODPATH/aioskernel/patch_qnn_backend_v73_fallback.py\" \"$AIOS_SNAP_QNN_LIB\" \"$AIOS_SNAP_QNN_PATCHED_LIB\""
EVAL "mv -f \"$AIOS_SNAP_QNN_PATCHED_LIB\" \"$AIOS_SNAP_QNN_LIB\""
unset AIOS_DECODED_APK AIOS_DECODED_LIB AIOS_DECODED_SSGEN_LIB AIOS_SSN_LIB AIOS_SSN_PATCHED_LIB AIOS_SNAP_QNN_LIB AIOS_SNAP_QNN_PATCHED_LIB S23U_FW_DIR AIOS_QNN_MISSING
SET_METADATA "system" "system/priv-app/AIOSKernelService" 0 0 755 "u:object_r:system_file:s0"
SET_METADATA "system" "system/priv-app/AIOSKernelService/AIOSKernelService.apk" 0 0 644 "u:object_r:system_file:s0"

LOG "- Re-signing AIOSKernelService.apk for SamsungAiCore signature-permission access"
AIOS_KERNEL_APK="$WORK_DIR/system/system/priv-app/AIOSKernelService/AIOSKernelService.apk"
AIOS_KERNEL_TMP="$TMP_DIR/aios_kernel_service"
AIOS_KERNEL_CERT_PREFIX="aosp"
$ROM_IS_OFFICIAL && AIOS_KERNEL_CERT_PREFIX="unica"
EVAL "rm -rf \"$AIOS_KERNEL_TMP\" && mkdir -p \"$AIOS_KERNEL_TMP\""
EVAL "signapk \"$SRC_DIR/security/${AIOS_KERNEL_CERT_PREFIX}_platform.x509.pem\" \"$SRC_DIR/security/${AIOS_KERNEL_CERT_PREFIX}_platform.pk8\" \"$AIOS_KERNEL_APK\" \"$AIOS_KERNEL_TMP/AIOSKernelService.signed.apk\""
EVAL "zipalign -c -p 4 \"$AIOS_KERNEL_TMP/AIOSKernelService.signed.apk\""
EVAL "mv -f \"$AIOS_KERNEL_TMP/AIOSKernelService.signed.apk\" \"$AIOS_KERNEL_APK\""
SET_METADATA "system" "system/priv-app/AIOSKernelService/AIOSKernelService.apk" 0 0 644 "u:object_r:system_file:s0"
EVAL "rm -rf \"$AIOS_KERNEL_TMP\""
unset AIOS_KERNEL_APK AIOS_KERNEL_TMP AIOS_KERNEL_CERT_PREFIX

for REZOSS_NOTI_AI_REQ in \
    "system/priv-app/SecSettings/SecSettings.apk" \
    "system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk" \
    "system/priv-app/SettingsProvider/SettingsProvider.apk" \
    "system/priv-app/SamsungIntelliVoiceServices/SamsungIntelliVoiceServices.apk" \
    "system/priv-app/SamsungAiCore/SamsungAiCore.apk" \
    "system/priv-app/AIOSKernelService/AIOSKernelService.apk" \
    "system/etc/permissions/privapp-permissions-com.samsung.android.intellivoiceservice.xml" \
    "system/etc/permissions/privapp-permissions-com.samsung.android.aicore.xml" \
    "system/etc/permissions/privapp-permissions-com.samsung.android.aioskernelservice.xml" \
    "system/etc/permissions/signature-permissions-com.samsung.android.offline.languagemodel.xml" \
    "system/etc/permissions/signature-permissions-downloadable.xml" \
    "system/etc/sysconfig/samsungintellivoiceservice.xml" \
    "system/etc/sysconfig/allowed-system-preload-apps.xml"; do
    if [ ! -f "$WORK_DIR/system/$REZOSS_NOTI_AI_REQ" ]; then
        LOGW "Notification highlights requirement missing: /system/$REZOSS_NOTI_AI_REQ"
    fi
done
unset REZOSS_NOTI_AI_REQ

LOG "- Patch SecSettings Notification highlights S26U gate"
APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "$MODPATH/notification-priority/SecSettings.apk/0001-Match-S26U-notification-highlights-gate.patch"

LOG "- Patch services.jar AI notification priority/summary model gate"
APPLY_PATCH "system" "system/framework/services.jar" \
    "$MODPATH/notification-priority/services.jar/0001-Allow-dm1q-dm2q-dm3q-AI-notification-priority.patch"

LOG "- Patch SettingsProvider notification priority/summary defaults"
APPLY_PATCH "system" "system/priv-app/SettingsProvider/SettingsProvider.apk" \
    "$MODPATH/notification-priority/SettingsProvider.apk/0001-Enable-notification-priority-default.patch"

# =============================================================================
# Firewall Region String Cleanup
# =============================================================================
if [ -f "$WORK_DIR/system/system/priv-app/Firewall/Firewall.apk" ]; then
    LOG "- Sanitize Firewall province/country strings"
    DECODE_APK "system" "system/priv-app/Firewall/Firewall.apk"
    python3 "$MODPATH/firewall/patch_region_strings.py" \
        "$APKTOOL_DIR/system/priv-app/Firewall/Firewall.apk" \
        "$MODPATH/firewall/region_names.tsv" \
        || LOGW "Failed to sanitize Firewall province/country strings, skipping..."
fi

LOG_STEP_OUT

# =============================================================================
# Kernel - Edgars + KernelSU-Next LKM + spoofed manager APK (shared helpers)
# =============================================================================
# shellcheck source=unica/mods/rezoss/kernel.sh
source "$MODPATH/kernel.sh"
# REZOSS_APPLY_KERNEL_PATCHES "edgars+ksu"
