#!/usr/bin/env bash
#
# Copyright (c) 2026 ALRIGROUP and its affiliates.
# Engineered and maintained by ALRI Development.
#
# This code is licensed under the ARGLP - ALRI GROUP LICENSE PERMISSIVE
# found in the LICENSE file in the root directory of this source tree
# and at: https://github.com/alrigroup/licenses
#
# =============================================================================
# UN1CA Carbon — Modular Telemetry & Bloatware Debloater
# Organization: ALRI Development (ALRIGROUP)
# Lead:         AlexsAR (@alexsanderalri)
# Systems:      AlexsanderALRI
#
# Logic:
#   Controls debloating via $DEBLOAT_TELEMETRY (default: true).
#   When true, prunes background telemetry, activity tracking, modem logging,
#   Qualcomm vendor demonstration prototypes, and partner bloatware from $WORK_DIR.
# =============================================================================

SKIPUNZIP=1

# Check if DEBLOAT_TELEMETRY is enabled (defaults to true if unset)
if [ "${DEBLOAT_TELEMETRY:-true}" != "true" ]; then
    if command -v LOG >/dev/null 2>&1; then
        LOG "- Telemetry debloat skipped (DEBLOAT_TELEMETRY=${DEBLOAT_TELEMETRY})"
    else
        echo "[-] Telemetry debloat skipped (DEBLOAT_TELEMETRY=${DEBLOAT_TELEMETRY})"
    fi
    return 0 2>/dev/null || exit 0
fi

if command -v LOG >/dev/null 2>&1; then
    LOG "- Executing UN1CA Carbon Telemetry Debloater (DEBLOAT_TELEMETRY=true)"
else
    echo "[*] Executing UN1CA Carbon Telemetry Debloater (DEBLOAT_TELEMETRY=true)"
fi

_debloat_target() {
    local partition="$1"
    local rel_work_dir="$2"
    local pkg_label="$3"

    # 1. UN1CA database prune and work_dir removal if DELETE_FROM_WORK_DIR is available
    if command -v DELETE_FROM_WORK_DIR >/dev/null 2>&1; then
        DELETE_FROM_WORK_DIR "$partition" "$rel_work_dir"
    fi

    # 2. Defensive direct removal across system-as-root and partition variants in $WORK_DIR
    if [ -n "$WORK_DIR" ]; then
        case "$partition" in
            "system")
                local subpath="${rel_work_dir#system/}"
                rm -rf "$WORK_DIR/system/system/$subpath" 2>/dev/null || true
                rm -rf "$WORK_DIR/system/$subpath" 2>/dev/null || true
                rm -rf "$WORK_DIR/system/$rel_work_dir" 2>/dev/null || true
                ;;
            "product")
                rm -rf "$WORK_DIR/product/$rel_work_dir" 2>/dev/null || true
                rm -rf "$WORK_DIR/system/product/$rel_work_dir" 2>/dev/null || true
                ;;
            "system_ext")
                rm -rf "$WORK_DIR/system_ext/$rel_work_dir" 2>/dev/null || true
                rm -rf "$WORK_DIR/system/system/system_ext/$rel_work_dir" 2>/dev/null || true
                rm -rf "$WORK_DIR/system/system_ext/$rel_work_dir" 2>/dev/null || true
                ;;
        esac
    fi

    if command -v LOG >/dev/null 2>&1; then
        LOG "  • Removed: $partition/$rel_work_dir ($pkg_label)"
    else
        echo "  • Removed: $partition/$rel_work_dir ($pkg_label)"
    fi
}

# --- System Partition Bloat (Telemetry, Analytics & Partner Services) ---
_debloat_target "system" "system/app/HiyaService" "Hiya Caller Spam Lookup"
_debloat_target "system" "system/app/SilentLog" "Modem Silent Logging Daemon"
# Note: SmartManager_v6_DeviceSecurity_CN is kept to provide com.samsung.android.sm.security.devicesecurityprovider for SmartManagerCN
_debloat_target "system" "system/priv-app/DeviceQualityAgent38" "Device Quality Agent (DQA)"
_debloat_target "system" "system/priv-app/DiagMonAgent97" "Diagnostic Monitor Agent"
_debloat_target "system" "system/priv-app/RubinVersion38" "Samsung Customization Service"
_debloat_target "system" "system/priv-app/WarrantyCare" "Warranty Care & Care+ Nag"
_debloat_target "system" "system/priv-app/knoxanalyticsagent" "Knox Analytics Agent"
_debloat_target "system" "system/priv-app/KmxService" "Knox Matrix Credential Sync"
_debloat_target "system" "system/bin/fabric_crypto" "Knox Matrix Fabric Crypto Daemon"
_debloat_target "system" "system/etc/init/fabric_crypto.rc" "Knox Matrix Daemon Init Trigger"
_debloat_target "system" "system/etc/permissions/FabricCryptoLib.xml" "Fabric Crypto Library Permission"
_debloat_target "system" "system/etc/permissions/privapp-permissions-com.samsung.android.kmxservice.xml" "Knox Matrix Privapp Permissions"
_debloat_target "system" "system/etc/sysconfig/preinstalled-packages-com.samsung.android.kmxservice.xml" "Knox Matrix Sysconfig"
_debloat_target "system" "system/etc/vintf/manifest/fabric_crypto_manifest.xml" "Fabric Crypto VINTF Manifest"
_debloat_target "system" "system/framework/FabricCryptoLib.jar" "Fabric Crypto Framework Library"

# --- Product Partition Bloat ---
_debloat_target "product" "priv-app/CarrierWifi" "Google Wi-Fi Carrier Auto-Provisioner"

# --- System_Ext Partition Bloat (Qualcomm OEM Sample / Demonstration Prototypes) ---
_debloat_target "system_ext" "priv-app/QaiorScreenUnderstandingService" "Qualcomm AI Screen Understanding Service"
_debloat_target "system_ext" "priv-app/screenunderstanding" "Qualcomm Screen Understanding Sample App"

# --- Sensor Wakelock & Standby Power Mitigations (Resolves Issue #11) ---
if [ -n "$WORK_DIR" ]; then
    LOG "- Mitigating sdhms physical activity sensor wakelocks"
    for perm_file in \
        "$WORK_DIR/system/system/etc/permissions/privapp-permissions-com.sec.android.sdhms.xml" \
        "$WORK_DIR/system/etc/permissions/privapp-permissions-com.sec.android.sdhms.xml"; do
        if [ -f "$perm_file" ]; then
            sed -i '/android.permission.ACTIVITY_RECOGNITION/d' "$perm_file" 2>/dev/null || true
            sed -i '/android.permission.BODY_SENSORS/d' "$perm_file" 2>/dev/null || true
        fi
    done
fi

unset -f _debloat_target
