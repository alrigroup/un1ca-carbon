# Show battery regulatory info in Settings
# Requires SEM_BATTERY_PROPERTY_IC_AUTHENTICATION_RESULT support
if [ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_BATTERY_SUPPORT_BSOH_SETTINGS")" ]; then
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_BATTERY_SUPPORT_BSOH_SETTINGS" --delete
fi
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_SETTINGS_ENABLE_EU_BATTERY_REGULATORY" "TRUE"

SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali/android/app/Instrumentation.smali" "replace" \
    'newApplication(Ljava/lang/Class;Landroid/content/Context;)Landroid/app/Application;' \
    'invoke-virtual {p0, p1}, Landroid/app/Application;->attach(Landroid/content/Context;)V' \
    '    invoke-virtual {p0, p1}, Landroid/app/Application;->attach(Landroid/content/Context;)V\n\n    invoke-static {p1}, Lio/mesalabs/unica/SamsungPropsHooks;->init(Landroid/content/Context;)V' \
    > /dev/null
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali/android/app/Instrumentation.smali" "replace" \
    'newApplication(Ljava/lang/ClassLoader;Ljava/lang/String;Landroid/content/Context;)Landroid/app/Application;' \
    'invoke-virtual {p0, p3}, Landroid/app/Application;->attach(Landroid/content/Context;)V' \
    '    invoke-virtual {p0, p3}, Landroid/app/Application;->attach(Landroid/content/Context;)V\n\n    invoke-static {p3}, Lio/mesalabs/unica/SamsungPropsHooks;->init(Landroid/content/Context;)V' \
    > /dev/null

DECODE_APK "system" "system/priv-app/SecSettings/SecSettings.apk"

# SoftwareUpdateUtils no longer exposes isOTAUpgradeAllowed(Context) on One UI 9.

# Always show One UI minor version
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali_classes3/com/samsung/android/settings/deviceinfo/softwareinfo/OneUIVersionPreferenceController.smali" "replace" \
    'isDeviceWithMicroVersion()Z' \
    'move-result p0' \
    'const/4 p0, 0x1'

# Show real device model number
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali_classes3/com/samsung/android/settings/deviceinfo/aboutphone/ModelNameGetter.smali" "replace" \
    'getModelName()Ljava/lang/String;' \
    'ro.product.model' \
    'ro.boot.em.model'

LOG_STEP_IN "- Adding UN1CA Settings"

# Dynamically patch SecSettings
# - Add missing/non-xml files in place
# - Patch existing files
#   - Use the first line of the file to tell sed how to apply the rest of the content
#   - Exception made for files under *res/values* where the "resources" tag gets nuked
while IFS= read -r f; do
    f="${f//$MODPATH\/SecSettings.apk\//}"

    if [[ "$f" == *"res/values"* ]] && [ -f "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$f" ]; then
        if grep -q "unica_allow_downgrade_title" "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$f"; then
            LOG "- \"$f\" already patched in SecSettings.apk, skipping..."
            continue
        fi
        LOG "- Patching \"$f\" in /system/system/priv-app/SecSettings.apk"
        PATCH_INST="/<\/resources>/i"
        CONTENT="$(sed -e "/?xml/d" -e "/resources>/d" "$MODPATH/SecSettings.apk/$f")"
        CONTENT="$(sed -e "s/\"/\\\\\"/g" -e "s/\\$/\\\\$/g" -e "s/ /\\\ /g" -e "s/\\\\n/\\\\\\\\\n/g" <<< "$CONTENT")"
        CONTENT="$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' <<< "$CONTENT")"
        EVAL "sed -i \"$PATCH_INST $CONTENT\" \"$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$f\""
    elif [ ! -f "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$f" ] || \
            [[ "$f" != *".xml" ]] || grep -qF "<?xml" "$MODPATH/SecSettings.apk/$f"; then
        LOG "- Adding \"$f\" to /system/system/priv-app/SecSettings.apk"
        mkdir -p "$(dirname "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$f")"
        cp -a "$MODPATH/SecSettings.apk/$f" "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$f"
    else
        LOG "- Patching \"$f\" in /system/system/priv-app/SecSettings.apk"
        PATCH_INST="$(head -n 1 "$MODPATH/SecSettings.apk/$f")"
        CONTENT="$(tail -n +2 "$MODPATH/SecSettings.apk/$f")"
        CONTENT="$(sed -e "s/\"/\\\\\"/g" -e "s/\\$/\\\\$/g" -e "s/ /\\\ /g" -e "s/\\\\n/\\\\\\\\\n/g" <<< "$CONTENT")"
        CONTENT="$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' <<< "$CONTENT")"
        EVAL "sed -i \"$PATCH_INST $CONTENT\" \"$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/$f\""
    fi
done < <(find "$MODPATH/SecSettings.apk" -type f \
    ! -name "*.bak*" \
    ! -name "*.orig" \
    ! -name "*.rej")

# Purge unsupported Privacy Display and badging artifacts on Galaxy S23 Base (Resolves Issues #2 & #5)
LOG "- Purging unsupported Privacy Display preferences and badging layouts"
sed -i '/privacy_display/d' "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/res/xml/sec_display_settings.xml" 2>/dev/null || true
sed -i '/pd_inset/d' "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/res/xml/sec_display_settings.xml" 2>/dev/null || true
sed -i 's/<bool name="config_pd_enable">true<\/bool>/<bool name="config_pd_enable">false<\/bool>/g' "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/res/values/bools.xml" 2>/dev/null || true
sed -i 's/android:layout="@layout\/sec_homepage_software_update_preference"//g' "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/res/xml/sec_top_level_settings.xml" 2>/dev/null || true
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_CONFIG_PRIVACY_DISPLAY" "0"

# Set default system window animations to 0.85x for enhanced UI snappiness
LOG "- Tuning default window animation scales to 0.85x"
WMS_SMALI=$(find "$APKTOOL_DIR/system/framework/services.jar" -type f -name "WindowManagerService.smali" 2>/dev/null | head -n 1)
if [ -n "$WMS_SMALI" ] && [ -f "$WMS_SMALI" ]; then
    sed -i "s/const\/high16 v3, 0x3f800000/const v3, 0x3f59999a    # 0.85f/g" "$WMS_SMALI"
fi

DECODE_APK "system" "system/priv-app/SettingsProvider/SettingsProvider.apk"
SP_DEFAULTS="$APKTOOL_DIR/system/priv-app/SettingsProvider/SettingsProvider.apk/res/values/defaults.xml"
if [ -f "$SP_DEFAULTS" ]; then
    LOG "- Setting SettingsProvider default animation scales to 0.85x"
    sed -i 's/<string name="def_window_animation_scale" translatable="false">1<\/string>/<string name="def_window_animation_scale" translatable="false">0.85<\/string>/g' "$SP_DEFAULTS"
    sed -i 's/<string name="def_window_transition_scale" translatable="false">1<\/string>/<string name="def_window_transition_scale" translatable="false">0.85<\/string>/g' "$SP_DEFAULTS"
    sed -i 's/<string name="def_animator_duration_scale" translatable="false">1<\/string>/<string name="def_animator_duration_scale" translatable="false">0.85<\/string>/g' "$SP_DEFAULTS"
fi

# Expose UN1CA-selected SamsungSans source-bank fonts through Samsung's normal
# Display > Font list and apply path.
LOG "- Patching Samsung font list integration in /system/system/priv-app/SecSettings.apk"
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali_classes3/com/samsung/android/settings/flipfont/FontListAdapter.smali" "replace" \
    'getInstanceFontListAdapter(Landroid/content/Context;)Lcom/samsung/android/settings/flipfont/FontListAdapter;' \
    'invoke-virtual/range {v3 .. v8}, Lcom/samsung/android/fontutil/TypefaceFinder;->getSansEntries(Landroid/content/Context;Landroid/content/pm/PackageManager;Ljava/util/ArrayList;Ljava/util/ArrayList;Ljava/util/ArrayList;)V' \
    '    invoke-virtual/range {v3 .. v8}, Lcom/samsung/android/fontutil/TypefaceFinder;->getSansEntries(Landroid/content/Context;Landroid/content/pm/PackageManager;Ljava/util/ArrayList;Ljava/util/ArrayList;Ljava/util/ArrayList;)V\n\n    invoke-static {v2}, Lio/mesalabs/unica/settings/font/FontListHook;->appendSelectedFonts(Lcom/samsung/android/settings/flipfont/FontListAdapter;)V' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali_classes3/com/samsung/android/settings/flipfont/FontListAdapter.smali" "replace" \
    'getFont(Ljava/lang/String;Ljava/lang/String;)Landroid/graphics/Typeface;' \
    'const-string v0, "fonts/"' \
    '    invoke-static {p0, p1, p2}, Lio/mesalabs/unica/settings/font/FontListHook;->getFont(Lcom/samsung/android/settings/flipfont/FontListAdapter;Ljava/lang/String;Ljava/lang/String;)Landroid/graphics/Typeface;\n\n    move-result-object v0\n\n    if-eqz v0, :cond_unica_font_original_getFont\n\n    return-object v0\n\n    :cond_unica_font_original_getFont\n    const-string v0, "fonts/"' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali_classes3/com/samsung/android/settings/display/SecFontStylePreferenceFragment.smali" "replace" \
    'onItemClick(ILandroid/view/View;)V' \
    'iget-object p2, p0, Lcom/samsung/android/settings/display/SecFontStylePreferenceFragment;->mContext:Landroid/content/Context;' \
    '    invoke-static {p1}, Lio/mesalabs/unica/settings/font/FontListHook;->isUnicaFontPackage(Ljava/lang/String;)Z\n\n    move-result v0\n\n    if-eqz v0, :cond_unica_font_original_apply\n\n    iget-object v0, p0, Lcom/samsung/android/settings/display/SecFontStylePreferenceFragment;->mFontListAdapter:Lcom/samsung/android/settings/flipfont/FontListAdapter;\n\n    iget-object v0, v0, Lcom/samsung/android/settings/flipfont/FontListAdapter;->mTypefaceFiles:Ljava/util/ArrayList;\n\n    iget v2, p0, Lcom/samsung/android/settings/display/SecFontStylePreferenceFragment;->mCurrentFontIndex:I\n\n    invoke-virtual {v0, v2}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;\n\n    move-result-object v0\n\n    check-cast v0, Ljava/lang/String;\n\n    invoke-virtual {v0}, Ljava/lang/String;->toString()Ljava/lang/String;\n\n    move-result-object v0\n\n    iget-object v2, p0, Lcom/samsung/android/settings/display/SecFontStylePreferenceFragment;->mFontListAdapter:Lcom/samsung/android/settings/flipfont/FontListAdapter;\n\n    iget-object v2, v2, Lcom/samsung/android/settings/flipfont/FontListAdapter;->mFontNames:Ljava/util/ArrayList;\n\n    iget v3, p0, Lcom/samsung/android/settings/display/SecFontStylePreferenceFragment;->mCurrentFontIndex:I\n\n    invoke-virtual {v2, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;\n\n    move-result-object v2\n\n    check-cast v2, Ljava/lang/String;\n\n    invoke-virtual {v2}, Ljava/lang/String;->toString()Ljava/lang/String;\n\n    move-result-object v2\n\n    iget-object v3, p0, Lcom/samsung/android/settings/display/SecFontStylePreferenceFragment;->mContext:Landroid/content/Context;\n\n    invoke-static {v3, v0, v2}, Lio/mesalabs/unica/settings/font/FontListHook;->applyUnicaFont(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Z\n\n    move-result v2\n\n    if-eqz v2, :cond_unica_font_apply_failed\n\n    goto/16 :goto_6\n\n    :cond_unica_font_apply_failed\n\n    invoke-virtual {p0, p1}, Lcom/samsung/android/settings/display/SecFontStylePreferenceFragment;->showWarningDialog(Ljava/lang/String;)V\n\n    return-void\n\n    :cond_unica_font_original_apply\n    iget-object p2, p0, Lcom/samsung/android/settings/display/SecFontStylePreferenceFragment;->mContext:Landroid/content/Context;' \
    > /dev/null

# Mark UN1CA Settings fragments as "valid"
LOG "- Patching \"smali/com/android/settings/core/gateway/SettingsGateway.smali\" in /system/system/priv-app/SecSettings.apk"
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali/com/android/settings/core/gateway/SettingsGateway.smali" "replace" \
    '<clinit>()V' \
    'filled-new-array/range {v1 .. v186}, [Ljava/lang/String;' \
    '    const-string v187, "io.mesalabs.unica.settings.UnicaSettingsFragment"\n\n    filled-new-array/range {v1 .. v187}, [Ljava/lang/String;' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali/com/android/settings/core/gateway/SettingsGateway.smali" "replace" \
    '<clinit>()V' \
    'filled-new-array/range {v1 .. v187}, [Ljava/lang/String;' \
    '    const-string v188, "io.mesalabs.unica.settings.extra.ExtraSettingsFragment"\n\n    filled-new-array/range {v1 .. v188}, [Ljava/lang/String;' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali/com/android/settings/core/gateway/SettingsGateway.smali" "replace" \
    '<clinit>()V' \
    'filled-new-array/range {v1 .. v188}, [Ljava/lang/String;' \
    '    const-string v189, "io.mesalabs.unica.settings.hma.HideMyApplistFragment"\n\n    filled-new-array/range {v1 .. v189}, [Ljava/lang/String;' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali/com/android/settings/core/gateway/SettingsGateway.smali" "replace" \
    '<clinit>()V' \
    'filled-new-array/range {v1 .. v189}, [Ljava/lang/String;' \
    '    const-string v190, "io.mesalabs.unica.settings.spoof.HideDeveloperStatusFragment"\n\n    filled-new-array/range {v1 .. v190}, [Ljava/lang/String;' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali/com/android/settings/core/gateway/SettingsGateway.smali" "replace" \
    '<clinit>()V' \
    'filled-new-array/range {v1 .. v190}, [Ljava/lang/String;' \
    '    const-string v191, "io.mesalabs.unica.settings.spoof.SpoofSettingsFragment"\n\n    filled-new-array/range {v1 .. v191}, [Ljava/lang/String;' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali/com/android/settings/core/gateway/SettingsGateway.smali" "replace" \
    '<clinit>()V' \
    'filled-new-array/range {v1 .. v191}, [Ljava/lang/String;' \
    '    const-string v192, "io.mesalabs.unica.settings.ui.UISettingsFragment"\n\n    filled-new-array/range {v1 .. v192}, [Ljava/lang/String;' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali/com/android/settings/core/gateway/SettingsGateway.smali" "replace" \
    '<clinit>()V' \
    'filled-new-array/range {v1 .. v192}, [Ljava/lang/String;' \
    '    const-string v193, "io.mesalabs.unica.settings.spoof.CameraFeatureFragment"\n\n    filled-new-array/range {v1 .. v193}, [Ljava/lang/String;' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali/com/android/settings/core/gateway/SettingsGateway.smali" "replace" \
    '<clinit>()V' \
    'filled-new-array/range {v1 .. v193}, [Ljava/lang/String;' \
    '    const-string v194, "io.mesalabs.unica.settings.font.FontSelectorFragment"\n\n    filled-new-array/range {v1 .. v194}, [Ljava/lang/String;' \
    > /dev/null
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali/com/android/settings/core/gateway/SettingsGateway.smali" "replace" \
    '<clinit>()V' \
    'filled-new-array/range {v1 .. v194}, [Ljava/lang/String;' \
    '    const-string v195, "io.mesalabs.unica.settings.extra.ScpmAllowlistFragment"\n\n    filled-new-array/range {v1 .. v195}, [Ljava/lang/String;' \
    > /dev/null

# Mark Privacy Display custom app fragment as "valid"
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali/com/android/settings/core/gateway/SettingsGateway.smali" "replace" \
    '<clinit>()V' \
    'filled-new-array/range {v1 .. v195}, [Ljava/lang/String;' \
    '    const-string v196, "com.samsung.android.settings.bpd.PdCustomAppsSettings"\n\n    filled-new-array/range {v1 .. v196}, [Ljava/lang/String;' \
    > /dev/null
LOG "- Patching \"smali/com/android/settings/SettingsActivity.smali\" in /system/system/priv-app/SecSettings.apk"
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali/com/android/settings/SettingsActivity.smali" "replace" \
    'isValidFragment(Ljava/lang/String;)Z' \
    'const/16 v2, 0xba' \
    'const/16 v2, 0xc4' \
    > /dev/null

# Add UN1CA Settings SearchIndexDataProvider(s)
LOG "- Patching Settings search index providers in /system/system/priv-app/SecSettings.apk"
SEARCH_INDEX_RESOURCES="$(
    find "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk" \
        -path '*/com/android/settings/search/SearchFeatureProviderImpl$$ExternalSyntheticLambda0.smali' \
        -print -quit
)"
if [ ! "$SEARCH_INDEX_RESOURCES" ]; then
    LOGE "Settings search provider registry not found in /system/system/priv-app/SecSettings.apk"
    return 1
fi
SEARCH_INDEX_RESOURCES_SMALI="${SEARCH_INDEX_RESOURCES#$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk/}"

ADD_UNICA_SETTINGS_SEARCH_INDEX_DATA_PROVIDER()
{
    local FRAGMENT="$1"

    if grep -q "L$FRAGMENT;->SEARCH_INDEX_DATA_PROVIDER" "$SEARCH_INDEX_RESOURCES"; then
        return 0
    fi

    SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
        "$SEARCH_INDEX_RESOURCES_SMALI" "replace" \
        'invoke()Ljava/lang/Object;' \
        'new-instance v0, Lcom/android/settingslib/spa/search/SearchIndexableDataConverter;' \
        "    new-instance v0, Lcom/android/settingslib/search/SearchIndexableData;\n\n    const-class v1, L$FRAGMENT;\n\n    sget-object v2, L$FRAGMENT;->SEARCH_INDEX_DATA_PROVIDER:Lcom/android/settings/search/BaseSearchIndexProvider;\n\n    invoke-direct {v0, v1, v2}, Lcom/android/settingslib/search/SearchIndexableData;-><init>(Ljava/lang/Class;Lcom/android/settingslib/search/Indexable\$SearchIndexProvider;)V\n\n    invoke-virtual {p0, v0}, Lcom/android/settingslib/search/SearchIndexableResourcesBase;->addIndex(Lcom/android/settingslib/search/SearchIndexableData;)V\n\n    new-instance v0, Lcom/android/settingslib/spa/search/SearchIndexableDataConverter;" \
        > /dev/null
}

for f in \
    "io/mesalabs/unica/settings/UnicaSettingsFragment" \
    "io/mesalabs/unica/settings/extra/ExtraSettingsFragment" \
    "io/mesalabs/unica/settings/spoof/HideDeveloperStatusFragment" \
    "io/mesalabs/unica/settings/spoof/SpoofSettingsFragment" \
    "io/mesalabs/unica/settings/ui/UISettingsFragment" \
    "io/mesalabs/unica/settings/spoof/CameraFeatureFragment" \
    "io/mesalabs/unica/settings/font/FontSelectorFragment" \
    "io/mesalabs/unica/settings/qwen/QwenSettingsFragment" \
    "io/mesalabs/unica/settings/extra/ScpmAllowlistFragment"; do
    ADD_UNICA_SETTINGS_SEARCH_INDEX_DATA_PROVIDER "$f" || return 1
done

DECODE_APK "system" "system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk"
LOG "- Patching Settings Intelligence top-level keys in /system/system/priv-app/SecSettingsIntelligence.apk"
TOP_LEVEL_KEYS_COLLECTOR="$(
    find "$APKTOOL_DIR/system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk" \
        -path '*/com/samsung/android/settings/intelligence/search/categorizing/TopLevelKeysCollector.smali' \
        -print -quit
)"
if [ ! "$TOP_LEVEL_KEYS_COLLECTOR" ]; then
    LOGE "TopLevelKeysCollector smali not found in /system/system/priv-app/SecSettingsIntelligence.apk"
    return 1
fi
TOP_LEVEL_KEYS_COLLECTOR_SMALI="${TOP_LEVEL_KEYS_COLLECTOR#$APKTOOL_DIR/system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk/}"

if ! grep -q '"top_level_unica"' "$TOP_LEVEL_KEYS_COLLECTOR"; then
    SMALI_PATCH "system" "system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk" \
        "$TOP_LEVEL_KEYS_COLLECTOR_SMALI" "replace" \
        '<init>(Landroid/content/Context;)V' \
        '.locals 37' \
        '.locals 38' \
        > /dev/null
    SMALI_PATCH "system" "system/priv-app/SecSettingsIntelligence/SecSettingsIntelligence.apk" \
        "$TOP_LEVEL_KEYS_COLLECTOR_SMALI" "replace" \
        '<init>(Landroid/content/Context;)V' \
        'filled-new-array/range {v1 .. v36}, [Ljava/lang/String;' \
        '    const-string v37, "top_level_unica"\n\n    filled-new-array/range {v1 .. v37}, [Ljava/lang/String;' \
        > /dev/null
fi

# Show Vulkan renderer toggle if required
if [[ "$(GET_PROP "ro.hwui.use_vulkan")" != "true" ]]; then
    SET_PROP "system" "persist.sys.unica.vulkan" "false"
fi

unset -f ADD_UNICA_SETTINGS_SEARCH_INDEX_DATA_PROVIDER
unset PATCH_INST CONTENT SEARCH_INDEX_RESOURCES SEARCH_INDEX_RESOURCES_SMALI TOP_LEVEL_KEYS_COLLECTOR TOP_LEVEL_KEYS_COLLECTOR_SMALI

# Purge precompiled stock oat/odex files so modified SecSettings.apk is loaded by Android runtime
if [ -d "$WORK_DIR/system/system/priv-app/SecSettings/oat" ]; then
    LOG "- Purging stock precompiled oat/odex for SecSettings"
    DELETE_FROM_WORK_DIR "system" "system/priv-app/SecSettings/oat" 2>/dev/null || true
    rm -rf "$WORK_DIR/system/system/priv-app/SecSettings/oat"
fi

# Preload Carbon animated video wallpaper
CARBON_VIDEO_WP="$SRC_DIR/carbon_ours/wallpapers/carbon_animated_lockscreen.mp4"
if [ ! -f "$CARBON_VIDEO_WP" ]; then
    CARBON_VIDEO_WP="/home/alexsanderalri/Documentos/Un1ca_Carbon/carbon_ours/wallpapers/carbon_animated_lockscreen.mp4"
fi
if [ -f "$CARBON_VIDEO_WP" ]; then
    LOG "- Preloading Carbon animated lockscreen video"
    mkdir -p "$WORK_DIR/system/system/media/video"
    cp -p "$CARBON_VIDEO_WP" "$WORK_DIR/system/system/media/video/carbon_animated_lockscreen.mp4"
    chmod 755 "$WORK_DIR/system/system/media/video"
    chmod 644 "$WORK_DIR/system/system/media/video/carbon_animated_lockscreen.mp4"
    SET_METADATA "system" "system/media/video" 0 0 755 "u:object_r:system_file:s0"
    SET_METADATA "system" "system/media/video/carbon_animated_lockscreen.mp4" 0 0 644 "u:object_r:system_file:s0"
fi

# Install GPU tuning SELinux policies and block labels
if [ -f "$SRC_DIR/carbon_ours/gpu_tuning/install-policy.py" ]; then
    LOG "- Installing GPU tuning SELinux policy"
    python3 "$SRC_DIR/carbon_ours/gpu_tuning/install-policy.py" "$WORK_DIR" || true
fi

LOG_STEP_OUT
