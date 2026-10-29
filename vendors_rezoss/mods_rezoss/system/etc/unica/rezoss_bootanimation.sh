#!/system/bin/sh
#
# Copyright (c) 2026 ALRIGROUP and its affiliates.
# Engineered and maintained by ALRI Development.
#
# UN1CA Carbon - Dynamic Boot Animation Controller
# Switch between:
# - "carbon"  : UN1CA Carbon (default)
# - "stock"   : Samsung One UI (Stock)
# - "rezoss"  : Android 17 (AOSP)
# Handled via persist.sys.unica.bootanim
#

LOG_TAG="CarbonBootAnim"

log_msg()
{
    log -t "$LOG_TAG" "$1"
}

STYLE="$(getprop persist.sys.unica.bootanim 2>/dev/null)"
[ -z "$STYLE" ] && STYLE="carbon"

CACHE_DIR="/data/misc/bootanim"
CACHE_ZIP="$CACHE_DIR/rezoss.zip"
CARBON_SRC="/system/media/bootanimation_carbon.zip"
[ -f "$CARBON_SRC" ] || CARBON_SRC="/system/media/bootanimation.zip"
SAMSUNG_SRC="/system/media/bootanimation_samsung.zip"

if [ "$STYLE" = "rezoss" ]; then
    log_msg "Switching to Android 17 (REZOSS): deleting active zip"
    rm -f "$CACHE_ZIP" 2>/dev/null
elif [ "$STYLE" = "stock" ] || [ "$STYLE" = "samsung" ]; then
    log_msg "Switching to Samsung One UI: activating stock animation"
    mkdir -p "$CACHE_DIR" 2>/dev/null
    if [ -f "$SAMSUNG_SRC" ]; then
        if [ ! -f "$CACHE_ZIP" ] || ! cmp -s "$SAMSUNG_SRC" "$CACHE_ZIP" 2>/dev/null; then
            cp -f "$SAMSUNG_SRC" "$CACHE_ZIP"
            chown system:system "$CACHE_ZIP" 2>/dev/null || true
            chmod 644 "$CACHE_ZIP" 2>/dev/null || true
            chcon u:object_r:bootanim_data_file:s0 "$CACHE_ZIP" 2>/dev/null || true
        fi
    fi
else
    log_msg "Switching to UN1CA Carbon: activating carbon animation"
    mkdir -p "$CACHE_DIR" 2>/dev/null
    if [ -f "$CARBON_SRC" ]; then
        if [ ! -f "$CACHE_ZIP" ] || ! cmp -s "$CARBON_SRC" "$CACHE_ZIP" 2>/dev/null; then
            cp -f "$CARBON_SRC" "$CACHE_ZIP"
            chown system:system "$CACHE_ZIP" 2>/dev/null || true
            chmod 644 "$CACHE_ZIP" 2>/dev/null || true
            chcon u:object_r:bootanim_data_file:s0 "$CACHE_ZIP" 2>/dev/null || true
        fi
    fi
fi

exit 0
