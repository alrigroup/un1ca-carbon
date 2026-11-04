#!/usr/bin/env bash
#
# Copyright (c) 2026 ALRIGROUP and its affiliates.
# Engineered and maintained by ALRI Development.
#
# This code is licensed under the ARGLP - ALRI GROUP LICENSE PERMISSIVE
# found in the LICENSE file in the root directory of this source tree
# and at: https://github.com/alrigroup/licenses
#
# Applied by scripts/internal/apply_modules.sh during make_rom.
SKIPUNZIP=1

if [ "$TARGET_CODENAME" != "dm1q" ]; then
    LOG "- Skipping GoRhanHee Kernel integration (target is not dm1q: ${TARGET_CODENAME:-unknown})"
    return 0 2>/dev/null || exit 0
fi

LOG_STEP_IN "- Integrating GoRhanHee Kernel (Linux 5.15.220 + KernelSU-Next + SUSFS) for Galaxy S23 (dm1q)"

GORHANHEE_DIR="$SRC_DIR/carbon_ours/kernel_gorhanhee"
[ -d "$GORHANHEE_DIR" ] || ABORT "GoRhanHee kernel directory not found: $GORHANHEE_DIR"

IMAGE_SRC="$GORHANHEE_DIR/Image"
VENDOR_DLKM_SRC="$GORHANHEE_DIR/vendor_dlkm.img"
SYSTEM_DLKM_SRC="$GORHANHEE_DIR/system_dlkm.img"
RAMDISK_MODULES_SRC="$GORHANHEE_DIR/sm8550_ramdisk/ramdisk/lib/modules"

# Ensure all assets are extracted
if [ ! -f "$IMAGE_SRC" ] || [ ! -f "$VENDOR_DLKM_SRC" ] || [ ! -f "$SYSTEM_DLKM_SRC" ] || [ ! -d "$RAMDISK_MODULES_SRC" ]; then
    if [ -f "$GORHANHEE_DIR/GoRhanHee_Kernel.zip" ]; then
        LOG "- Extracting missing GoRhanHee assets from zip..."
        unzip -qo "$GORHANHEE_DIR/GoRhanHee_Kernel.zip" -d "$GORHANHEE_DIR" "Image" "vendor_dlkm.img" "system_dlkm.img" "sm8550_ramdisk/*" || ABORT "Failed to extract GoRhanHee assets from zip"
    else
        ABORT "Missing GoRhanHee assets and GoRhanHee_Kernel.zip not found in $GORHANHEE_DIR"
    fi
fi

[ -f "$IMAGE_SRC" ] || ABORT "GoRhanHee Image not found at $IMAGE_SRC"
[ -f "$VENDOR_DLKM_SRC" ] || ABORT "GoRhanHee vendor_dlkm.img not found at $VENDOR_DLKM_SRC"
[ -f "$SYSTEM_DLKM_SRC" ] || ABORT "GoRhanHee system_dlkm.img not found at $SYSTEM_DLKM_SRC"
[ -d "$RAMDISK_MODULES_SRC" ] || ABORT "GoRhanHee ramdisk modules not found at $RAMDISK_MODULES_SRC"

# Locate magiskboot
MAGISKBOOT=""
for candidate in \
    "$MODPATH/tools/magiskboot" \
    "$SRC_DIR/prebuilts/tools/linux-x86/magiskboot" \
    "$TOOLS_DIR/bin/magiskboot" \
    "$(command -v magiskboot 2>/dev/null || true)"; do
    if [ -n "$candidate" ] && [ -x "$candidate" ]; then
        MAGISKBOOT="$(realpath "$candidate")"
        break
    fi
done

mkdir -p "${TMP_DIR:-/tmp}"
ENGINE_TMP="$(mktemp -d "${TMP_DIR:-/tmp}/kernel_engine.XXXXXX")"
trap 'rm -rf "$ENGINE_TMP"' EXIT INT TERM

# =============================================================================
# 1. REPACK BOOT.IMG WITH GORHANHEE IMAGE
# =============================================================================
TARGET_BOOT="$WORK_DIR/kernel/boot.img"
if [ -f "$TARGET_BOOT" ]; then
    LOG "- Repacking boot.img with GoRhanHee Linux 5.15.220 kernel Image..."
    BOOT_TMP="$ENGINE_TMP/boot"
    mkdir -p "$BOOT_TMP"
    cp -f "$TARGET_BOOT" "$BOOT_TMP/boot.img"

    REPACK_BOOT_OK=false
    if [ -n "$MAGISKBOOT" ]; then
        (
            cd "$BOOT_TMP" || exit 1
            "$MAGISKBOOT" unpack -n -h boot.img || exit 1
            cp -f "$IMAGE_SRC" kernel || exit 1
            PATCHVBMETAFLAG=false "$MAGISKBOOT" repack boot.img new-boot.img || exit 1
            [ -f new-boot.img ] || exit 1
            cp -f new-boot.img "$TARGET_BOOT" || exit 1
        ) && REPACK_BOOT_OK=true
    fi

    if [ "$REPACK_BOOT_OK" != true ] && command -v unpack_bootimg >/dev/null 2>&1 && command -v mkbootimg >/dev/null 2>&1; then
        LOG "- Falling back to unpack_bootimg / mkbootimg for boot.img..."
        (
            cd "$BOOT_TMP" || exit 1
            rm -rf unpack_out
            mkdir -p unpack_out
            unpack_bootimg --boot_img boot.img --out unpack_out --format=mkbootimg -0 > unpack_out/args || exit 1
            declare -a MKBOOTIMG_ARGS=()
            while IFS= read -r -d '' ARG; do
                MKBOOTIMG_ARGS+=("${ARG}")
            done < unpack_out/args
            cp -f "$IMAGE_SRC" unpack_out/kernel || exit 1
            mkbootimg "${MKBOOTIMG_ARGS[@]}" -o new-boot.img || exit 1
            [ -f new-boot.img ] || exit 1
            cp -f new-boot.img "$TARGET_BOOT" || exit 1
        ) && REPACK_BOOT_OK=true
    fi

    if [ "$REPACK_BOOT_OK" != true ]; then
        ABORT "Failed to repack boot.img with GoRhanHee kernel Image"
    fi
    LOG "  ✔ boot.img successfully repacked with GoRhanHee Kernel."
else
    LOGW "Target boot.img not found at $TARGET_BOOT; skipping boot.img repack."
fi

# =============================================================================
# 2. REPACK VENDOR_BOOT.IMG WITH GORHANHEE RAMDISK MODULES
# =============================================================================
TARGET_VBOOT="$WORK_DIR/kernel/vendor_boot.img"
if [ -f "$TARGET_VBOOT" ]; then
    LOG "- Repacking vendor_boot.img with GoRhanHee ramdisk modules & patched fstab..."
    VBOOT_TMP="$ENGINE_TMP/vendor_boot"
    mkdir -p "$VBOOT_TMP"
    cp -f "$TARGET_VBOOT" "$VBOOT_TMP/vendor_boot.img"

    REPACK_VBOOT_OK=false
    if [ -n "$MAGISKBOOT" ]; then
        (
            cd "$VBOOT_TMP" || exit 1
            "$MAGISKBOOT" unpack -n -h vendor_boot.img
            vb_status=$?
            case "$vb_status" in 0|3) ;; *) exit 1 ;; esac

            # Find vendor ramdisk fragment
            RAMDISK_RAW=""
            for cand in ramdisk.cpio vendor_ramdisk/*.cpio vendor_ramdisk/ramdisk.cpio; do
                if [ -f "$cand" ]; then
                    RAMDISK_RAW="$cand"
                    break
                fi
            done
            [ -n "$RAMDISK_RAW" ] || exit 1

            # Decompress ramdisk
            if cpio -it -F "$RAMDISK_RAW" >/dev/null 2>&1; then
                cp -f "$RAMDISK_RAW" platform.cpio
            else
                "$MAGISKBOOT" decompress "$RAMDISK_RAW" platform.cpio || exit 1
            fi

            # Extract first_stage_ramdisk/fstab.qcom if present and patch DLKM AVB flags
            if "$MAGISKBOOT" cpio platform.cpio "exists first_stage_ramdisk/fstab.qcom"; then
                "$MAGISKBOOT" cpio platform.cpio "extract first_stage_ramdisk/fstab.qcom fstab.qcom" || exit 1
                awk '
                    BEGIN { OFS = "\t" }
                    $1 == "vendor_dlkm" || $1 == "system_dlkm" {
                        count = split($5, flags, ",")
                        value = ""
                        for (i = 1; i <= count; i++) {
                            if (flags[i] ~ /^avb(=|$)/)
                                continue
                            value = value (value == "" ? "" : ",") flags[i]
                        }
                        $5 = value
                    }
                    { print }
                ' fstab.qcom > fstab.qcom.tmp && mv -f fstab.qcom.tmp fstab.qcom
            fi

            # Build list of old module entries to remove from cpio
            cpio -it -F platform.cpio > module-entries || exit 1
            CPIO_ACTIONS=()
            while IFS= read -r entry; do
                case "$entry" in
                    lib/modules|lib/modules/*|./lib/modules|./lib/modules/*)
                        CPIO_ACTIONS+=("rm $entry")
                        ;;
                esac
            done < module-entries

            # Add new directories and modules
            CPIO_ACTIONS+=("mkdir 0755 lib" "mkdir 0755 lib/modules")
            for mod in "$RAMDISK_MODULES_SRC"/*; do
                [ -f "$mod" ] || continue
                mod_name="${mod##*/}"
                CPIO_ACTIONS+=("add 0644 lib/modules/$mod_name $mod")
            done

            if [ -f fstab.qcom ]; then
                CPIO_ACTIONS+=("add 0644 first_stage_ramdisk/fstab.qcom fstab.qcom")
            fi

            "$MAGISKBOOT" cpio platform.cpio "${CPIO_ACTIONS[@]}" || exit 1
            "$MAGISKBOOT" compress=lz4_legacy platform.cpio "$RAMDISK_RAW" || exit 1
            PATCHVBMETAFLAG=false "$MAGISKBOOT" repack vendor_boot.img new-vendor_boot.img || exit 1
            [ -f new-vendor_boot.img ] || exit 1
            cp -f new-vendor_boot.img "$TARGET_VBOOT" || exit 1
        ) && REPACK_VBOOT_OK=true
    fi

    if [ "$REPACK_VBOOT_OK" != true ]; then
        ABORT "Failed to repack vendor_boot.img with GoRhanHee ramdisk modules"
    fi
    LOG "  ✔ vendor_boot.img successfully repacked with GoRhanHee ramdisk modules."
else
    LOGW "Target vendor_boot.img not found at $TARGET_VBOOT; skipping vendor_boot repack."
fi

# =============================================================================
# 3. EXTRACT GORHANHEE DLKM MODULES & UPDATE FS_CONFIG / FILE_CONTEXTS
# =============================================================================
LOG "- Extracting GoRhanHee vendor_dlkm and system_dlkm..."

DLKM_EXTRACT_TMP="$ENGINE_TMP/dlkm_extract"
mkdir -p "$DLKM_EXTRACT_TMP/vendor_dlkm" "$DLKM_EXTRACT_TMP/system_dlkm"

if command -v fsck.erofs >/dev/null 2>&1; then
    fsck.erofs --extract="$DLKM_EXTRACT_TMP/vendor_dlkm" "$VENDOR_DLKM_SRC" || ABORT "Failed to extract vendor_dlkm.img"
    fsck.erofs --extract="$DLKM_EXTRACT_TMP/system_dlkm" "$SYSTEM_DLKM_SRC" || ABORT "Failed to extract system_dlkm.img"
else
    ABORT "fsck.erofs not found in PATH; required for extracting GoRhanHee DLKM images"
fi

# Update $WORK_DIR/vendor_dlkm
mkdir -p "$WORK_DIR/vendor_dlkm/lib/modules"
LOG "- Replacing modules in $WORK_DIR/vendor_dlkm/lib/modules..."
rm -rf "$WORK_DIR/vendor_dlkm/lib/modules"
mkdir -p "$WORK_DIR/vendor_dlkm/lib/modules"
cp -a "$DLKM_EXTRACT_TMP/vendor_dlkm/lib/modules/"* "$WORK_DIR/vendor_dlkm/lib/modules/"
if [ -d "$DLKM_EXTRACT_TMP/vendor_dlkm/etc" ]; then
    mkdir -p "$WORK_DIR/vendor_dlkm/etc"
    cp -a "$DLKM_EXTRACT_TMP/vendor_dlkm/etc/"* "$WORK_DIR/vendor_dlkm/etc/"
fi

# Update $WORK_DIR/system_dlkm
mkdir -p "$WORK_DIR/system_dlkm/lib/modules"
LOG "- Replacing modules in $WORK_DIR/system_dlkm/lib/modules..."
rm -rf "$WORK_DIR/system_dlkm/lib/modules"
mkdir -p "$WORK_DIR/system_dlkm/lib/modules"
cp -a "$DLKM_EXTRACT_TMP/system_dlkm/lib/modules/"* "$WORK_DIR/system_dlkm/lib/modules/"
if [ -d "$DLKM_EXTRACT_TMP/system_dlkm/etc" ]; then
    mkdir -p "$WORK_DIR/system_dlkm/etc"
    cp -a "$DLKM_EXTRACT_TMP/system_dlkm/etc/"* "$WORK_DIR/system_dlkm/etc/"
fi

# Regenerate fs_config and file_contexts for vendor_dlkm and system_dlkm
REBUILD_PARTITION_CONFIGS() {
    local PART="$1"
    local PART_DIR="$WORK_DIR/$PART"
    local FSC="$WORK_DIR/configs/fs_config-$PART"
    local FC="$WORK_DIR/configs/file_context-$PART"

    [ -d "$PART_DIR" ] || return 0

    LOG "- Regenerating fs_config and file_contexts for $PART..."
    mkdir -p "$WORK_DIR/configs"

    echo " 0 0 755 capabilities=0x0" > "$FSC"
    if [ "$PART" = "system_dlkm" ]; then
        echo "/$PART u:object_r:system_dlkm_file:s0" > "$FC"
    else
        echo "/$PART u:object_r:vendor_file:s0" > "$FC"
        echo "/$PART/etc u:object_r:vendor_configs_file:s0" >> "$FC"
    fi

    while IFS= read -r item; do
        rel="${item#$PART_DIR/}"
        [ -n "$rel" ] || continue
        esc_rel="$(echo "$rel" | sed -e 's/[.[\*^$()+?{|]/\\&/g')"
        if [ -d "$item" ]; then
            if [ "$PART" = "system_dlkm" ]; then
                echo "$PART/$rel 0 0 755 capabilities=0x0" >> "$FSC"
                echo "/$PART/$esc_rel u:object_r:system_dlkm_file:s0" >> "$FC"
            else
                if [[ "$rel" == "etc"* ]]; then
                    echo "$PART/$rel 0 0 755 capabilities=0x0" >> "$FSC"
                    echo "/$PART/$esc_rel u:object_r:vendor_configs_file:s0" >> "$FC"
                else
                    echo "$PART/$rel 0 0 755 capabilities=0x0" >> "$FSC"
                    echo "/$PART/$esc_rel u:object_r:vendor_file:s0" >> "$FC"
                fi
            fi
        else
            if [ "$PART" = "system_dlkm" ]; then
                echo "$PART/$rel 0 0 644 capabilities=0x0" >> "$FSC"
                echo "/$PART/$esc_rel u:object_r:system_dlkm_file:s0" >> "$FC"
            else
                if [[ "$rel" == "etc"* ]]; then
                    echo "$PART/$rel 0 0 644 capabilities=0x0" >> "$FSC"
                    echo "/$PART/$esc_rel u:object_r:vendor_configs_file:s0" >> "$FC"
                else
                    echo "$PART/$rel 0 0 644 capabilities=0x0" >> "$FSC"
                    echo "/$PART/$esc_rel u:object_r:vendor_file:s0" >> "$FC"
                fi
            fi
        fi
    done < <(find "$PART_DIR" -mindepth 1 | sort)
}

REBUILD_PARTITION_CONFIGS "vendor_dlkm"
REBUILD_PARTITION_CONFIGS "system_dlkm"

LOG_STEP_OUT
LOG "✔ GoRhanHee Kernel and matching DLKMs integrated successfully for dm1q."
