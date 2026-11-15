#!/system/bin/sh

STATE_KEY="unica_now_nudge_experimental"
LOG_FILE="/data/system/unica_now_nudge_defaults.log"
SMARTSUGGESTIONS_PREF_FILE="/data/user/0/com.samsung.android.smartsuggestions/shared_prefs/com.samsung.android.smartsuggestions_preferences.xml"

log_msg() {
    mkdir -p /data/system
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null)" "$*" >> "$LOG_FILE" 2>/dev/null
}

log_msg "start"

set_xml_boolean_pref() {
    FILE="$1"
    KEY="$2"
    VALUE="$3"

    if [ ! -f "$FILE" ]; then
        log_msg "skip pref $KEY: missing $FILE"
        return 0
    fi

    if grep -q "name=\"$KEY\"" "$FILE" 2>/dev/null; then
        sed -i "s#<boolean name=\"$KEY\" value=\"[^\"]*\" */>#<boolean name=\"$KEY\" value=\"$VALUE\" />#g" "$FILE" 2>/dev/null
    elif grep -q '</map>' "$FILE" 2>/dev/null; then
        sed -i "/<\/map>/i\\    <boolean name=\"$KEY\" value=\"$VALUE\" />" "$FILE" 2>/dev/null
    else
        log_msg "skip pref $KEY: invalid xml"
        return 0
    fi

    restorecon "$FILE" 2>/dev/null
    log_msg "set pref $KEY=$VALUE"
}

set_appop() {
    PKG="$1"
    OP="$2"
    MODE="$3"

    if cmd appops set "$PKG" "$OP" "$MODE" >/dev/null 2>&1; then
        log_msg "set appop $PKG $OP=$MODE"
    else
        log_msg "failed appop $PKG $OP=$MODE"
    fi
}

STATE="$(settings get system "$STATE_KEY" 2>/dev/null)"
case "$STATE" in
    0|false|FALSE)
        log_msg "skip: $STATE_KEY explicitly disabled"
        exit 0
        ;;
esac

settings put system "$STATE_KEY" 1 >/dev/null 2>&1
settings put global sss_enabled 1 >/dev/null 2>&1
settings put global now_nudge_setting 1 >/dev/null 2>&1
settings put global now_nudge_enabled 1 >/dev/null 2>&1
settings put global nowbrief_enabled 1 >/dev/null 2>&1
settings put global smart_suggestions_enabled 1 >/dev/null 2>&1
settings put global app_widget_brief_type 1 >/dev/null 2>&1
settings put global brief_now_bar_need_to_unlock 0 >/dev/null 2>&1
settings put global show_brief_without_unlock 1 >/dev/null 2>&1
settings put system ai_info_confirmed 1 >/dev/null 2>&1
settings put system suggested_replies_state 1 >/dev/null 2>&1
settings put system key_now_bar_com_samsung_android_smartsuggestions 1 >/dev/null 2>&1
settings put system now_bar_aod_enabled 1 >/dev/null 2>&1
settings put secure content_capture_enabled 1 >/dev/null 2>&1
settings put secure suggested_replies 1 >/dev/null 2>&1
settings put secure noti_intelligence_first_time 1 >/dev/null 2>&1
settings put secure noti_intelligence_priority_content 1 >/dev/null 2>&1
settings put system noti_intelligence_priority_conversation 1 >/dev/null 2>&1
settings put secure noti_intelligence_summarize_content 1 >/dev/null 2>&1

# Sincronizar permissão do Writing Assistant para todos os idiomas do Teclado Samsung
for json_file in "/data/user/0/com.samsung.android.honeyboard/files/selected.json" "/data/user_de/0/com.samsung.android.honeyboard/files/selected.json"; do
    if [ -f "$json_file" ] && ! grep -q '"writing_assistant"' "$json_file" 2>/dev/null; then
        sed -i 's/"auto_spacing"/"auto_spacing","writing_assistant"/g' "$json_file" 2>/dev/null
        restorecon "$json_file" 2>/dev/null
        log_msg "injected writing_assistant into $json_file"
    fi
done

set_appop "com.samsung.android.smartsuggestions" "GET_USAGE_STATS" "allow"

set_xml_boolean_pref "$SMARTSUGGESTIONS_PREF_FILE" "smart_commute" "true"
set_xml_boolean_pref "$SMARTSUGGESTIONS_PREF_FILE" "key_manage_personal_data_driving_status" "true"
set_xml_boolean_pref "$SMARTSUGGESTIONS_PREF_FILE" "traffic_updates" "true"
set_xml_boolean_pref "$SMARTSUGGESTIONS_PREF_FILE" "google_map" "true"

log_msg "enabled Now Nudge defaults"
