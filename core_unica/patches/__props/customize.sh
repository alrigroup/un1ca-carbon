# Property identifying the UN1CA version
SET_PROP "system" "ro.unica.version" "UN1CA Carbon IX 1.2.1"
SET_PROP "system" "ro.unica.codename" "Carbon IX"
SET_PROP "system" "ro.unica.maintainer" "ALRI Development (Lead: AlexsAR)"
SET_PROP "system" "ro.unica.porter" "ALRI Development (Lead: AlexsanderALRI)"
SET_PROP "system" "ro.npl.maintainer" "ALRI Development (Lead: AlexsAR)"
SET_PROP "system" "ro.npl.maintainers" "ALRI Development (Lead: AlexsAR)"
EVAL "echo \"ro.unica.version u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""
EVAL "echo \"ro.unica.codename u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""
EVAL "echo \"ro.unica.maintainer u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""
EVAL "echo \"ro.unica.porter u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""
EVAL "echo \"ro.npl.maintainer u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""
EVAL "echo \"ro.npl.maintainers u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""

# Property identifying the UN1CA build time
SET_PROP "system" "ro.unica.timestamp" "$ROM_BUILD_TIMESTAMP"
EVAL "echo \"ro.unica.timestamp u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""

# Property identifying the device codename UN1CA is being built for
SET_PROP "system" "ro.unica.device" "$TARGET_CODENAME"
EVAL "echo \"ro.unica.device u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""

# Wi-Fi Display / Miracast / Wireless DeX HDCP bypass for Knox 0x1
SET_PROP "system" "wlan.wfd.hdcp" "disable"
SET_PROP "system" "persist.sys.wfd.hdcp" "disable"

# Property identifying the UN1CA build as a whole
# This bundles the properties which aren't already part of Android OS
# unica/<ro.unica.device>:<MAJOR.MINOR.PATCH from ro.unica.version>/<8-digit commit hash from ro.unica.version><.dirty>/<ro.unica.timestamp>:<user/userdebug>/<release/test>-keys

# unica header + the target codename
FINGERPRINT="unica/${TARGET_CODENAME}:"

# version value is UN1CA version
VER_NUM="$(grep -o "[0-9]\+\.[0-9]\+\(\.[0-9]\+\)\?" <<< "$ROM_VERSION" | head -n 1 || true)"
[ -n "$VER_NUM" ] || VER_NUM="1.0"
FINGERPRINT+="${VER_NUM}/"

# build ID value is the UN1CA commit
BUILD_ID="$(cut -d "-" -f 2 <<< "$ROM_VERSION")"
[ -n "$BUILD_ID" ] || BUILD_ID="carbon"
FINGERPRINT+="${BUILD_ID}"
# append .dirty if dirty
if grep -q -- "-dirty" <<< "$ROM_VERSION" 2>/dev/null; then
    FINGERPRINT+=".dirty/"
else
    FINGERPRINT+="/"
fi

# incremental value matching the UN1CA build timestamp
FINGERPRINT+="${ROM_BUILD_TIMESTAMP}:"

# user/userdebug reflecting $DEBUG
if $DEBUG; then
    FINGERPRINT+="userdebug/"
else
    FINGERPRINT+="user/"
fi

# test-keys/release-keys for $ROM_IS_OFFICIAL
if $ROM_IS_OFFICIAL; then
    FINGERPRINT+="release-keys"
else
    FINGERPRINT+="test-keys"
fi

SET_PROP "system" "ro.unica.fingerprint" "$FINGERPRINT"
EVAL "echo \"ro.unica.fingerprint u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""

unset FINGERPRINT
