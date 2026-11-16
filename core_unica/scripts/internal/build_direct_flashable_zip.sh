#!/usr/bin/env bash
# Copyright (c) 2026 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# [
source "$SRC_DIR/scripts/utils/install_utils.sh" || exit 1

TMP_DIR="$OUT_DIR/target/$TARGET_CODENAME/zip"

PRIVATE_KEY_PATH="$SRC_DIR/security/"
PUBLIC_KEY_PATH="$SRC_DIR/security/"
if $ROM_IS_OFFICIAL; then
    PRIVATE_KEY_PATH+="unica_ota"
    PUBLIC_KEY_PATH+="unica_ota"
else
    PRIVATE_KEY_PATH+="aosp_testkey"
    PUBLIC_KEY_PATH+="aosp_testkey"
fi
PRIVATE_KEY_PATH+=".pk8"
PUBLIC_KEY_PATH+=".x509.pem"

trap 'rm -rf "$TMP_DIR"' EXIT INT

# https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/tools/releasetools/build_super_image.py#72
BUILD_SUPER_EMPTY()
{
    local CMD

    CMD="lpmake"
    # https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/tools/releasetools/build_super_image.py#75
    CMD+=" --metadata-size \"65536\""
    # https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/core/config.mk#1033
    CMD+=" --super-name \"super\""
    # https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/tools/releasetools/build_super_image.py#85
    CMD+=" --metadata-slots \"2\""
    CMD+=" --device \"super:$TARGET_SUPER_PARTITION_SIZE\""
    CMD+=" --group \"$TARGET_SUPER_GROUP_NAME:$(GET_SUPER_GROUP_SIZE)\""
    for p in $PARTITIONS_LIST; do
        if [ -f "$TMP_DIR/$p.img" ]; then
            CMD+=" --partition \"$p:readonly:0:$TARGET_SUPER_GROUP_NAME\""
        fi
    done
    CMD+=" --output \"$TMP_DIR/unsparse_super_empty.img\""

    EVAL "$CMD" || exit 1
}

GENERATE_BUILD_INFO()
{
    local SOURCE_FIRMWARE_PATH
    local TARGET_FIRMWARE_PATH
    local SOURCE_FINGERPRINT
    local TARGET_FINGERPRINT

    SOURCE_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")"
    TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"

    SOURCE_FINGERPRINT="$(GET_PROP "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/build.prop" "ro.system.build.fingerprint")"
    SOURCE_FINGERPRINT="${SOURCE_FINGERPRINT//$(GET_PROP "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/system/build.prop" "ro.build.product")/$(GET_PROP "$FW_DIR/$SOURCE_FIRMWARE_PATH/vendor/build.prop" "ro.product.vendor.device")}"
    TARGET_FINGERPRINT="$(GET_PROP "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/build.prop" "ro.system.build.fingerprint")"
    TARGET_FINGERPRINT="${TARGET_FINGERPRINT//$(GET_PROP "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/build.prop" "ro.build.product")/$(GET_PROP "$FW_DIR/$TARGET_FIRMWARE_PATH/vendor/build.prop" "ro.product.vendor.device")}"

    echo -n "device="
    [ "$(GET_PROP "system" "ro.unica.device")" ] && GET_PROP "system" "ro.unica.device" || echo "$TARGET_CODENAME"
    [ "$TARGET_ASSERT_MODEL" ] && echo "model=${TARGET_ASSERT_MODEL//:/;}"
    echo "name=$TARGET_NAME"
    echo -n "version="
    [ "$(GET_PROP "system" "ro.unica.version")" ] && GET_PROP "system" "ro.unica.version" || echo "$ROM_VERSION"
    echo -n "timestamp="
    [ "$(GET_PROP "system" "ro.unica.timestamp")" ] && GET_PROP "system" "ro.unica.timestamp" || echo "$ROM_BUILD_TIMESTAMP"
    echo "os_version=$(GET_PROP "system" "ro.build.version.release")"
    echo "oneui_version=$(GET_PROP "system" "ro.build.version.oneui")"
    echo "build_incremental=$(GET_PROP "system" "ro.build.version.incremental")"
    echo "build_date=$(GET_PROP "system" "ro.build.date.utc")"
    echo "security_patch=$(GET_PROP "system" "ro.build.version.security_patch")"
    echo "source_fingerprint=$SOURCE_FINGERPRINT"
    echo "target_fingerprint=$TARGET_FINGERPRINT"
    echo "use_dynamic_partitions=$TARGET_USE_DYNAMIC_PARTITIONS"
    if $TARGET_USE_DYNAMIC_PARTITIONS; then
        echo "super_partition_size=$TARGET_SUPER_PARTITION_SIZE"
        echo "super_partition_group=$TARGET_SUPER_GROUP_NAME"
        echo "super_${TARGET_SUPER_GROUP_NAME}_group_size=$(GET_SUPER_GROUP_SIZE)"
    fi
}

GENERATE_OP_LIST()
{
    local OP_LIST_FILE="$TMP_DIR/dynamic_partitions_op_list"

    local SUPER_GROUP_NAME
    local SUPER_GROUP_SIZE

    SUPER_GROUP_NAME="$(grep "^super_partition_group" <<< "$BUILD_INFO" | cut -d "=" -f 2 -s)"
    SUPER_GROUP_SIZE="$(grep "^super_${SUPER_GROUP_NAME}_group_size" <<< "$BUILD_INFO" | cut -d "=" -f 2 -s)"

    local PARTITION_SIZE=0
    local OCCUPIED_SPACE=0

    {
        echo "# Remove all existing dynamic partitions and groups before applying full OTA"
        echo "remove_all_groups"
        echo "# Add group $SUPER_GROUP_NAME with maximum size $SUPER_GROUP_SIZE"
        echo "add_group $SUPER_GROUP_NAME $SUPER_GROUP_SIZE"
        for p in $PARTITIONS_LIST; do
            if [ -f "$TMP_DIR/$p.img" ]; then
                echo "# Add partition $p to group $SUPER_GROUP_NAME"
                echo "add $p $SUPER_GROUP_NAME"
            fi
        done
        for p in $PARTITIONS_LIST; do
            if [ -f "$TMP_DIR/$p.img" ]; then
                PARTITION_SIZE="$(GET_IMAGE_SIZE "$TMP_DIR/$p.img")"
                echo "# Grow partition $p from 0 to $PARTITION_SIZE"
                echo "resize $p $PARTITION_SIZE"
                OCCUPIED_SPACE=$((OCCUPIED_SPACE + PARTITION_SIZE))
            fi
        done
    } > "$OP_LIST_FILE"

    if [ "$OCCUPIED_SPACE" -gt "$SUPER_GROUP_SIZE" ]; then
        LOGE "OS size ($OCCUPIED_SPACE) is bigger than the target group size ($SUPER_GROUP_SIZE)"
        exit 1
    fi
}

GENERATE_OTA_METADATA()
{
    local PROTO_FILE="$SRC_DIR/external/android-tools/vendor/build/tools/releasetools/ota_metadata.proto"

    local DEVICE
    local RELEASE
    local INCREMENTAL
    local TIMESTAMP
    local SECURITY_PATCH_LEVEL
    local FINGERPRINT

    DEVICE="$(grep "^device" <<< "$BUILD_INFO" | cut -d "=" -f 2 -s)"
    RELEASE="$(grep "^os_version" <<< "$BUILD_INFO" | cut -d "=" -f 2 -s)"
    INCREMENTAL="$(grep "^build_incremental" <<< "$BUILD_INFO" | cut -d "=" -f 2 -s)"
    TIMESTAMP="$(grep "^build_date" <<< "$BUILD_INFO" | cut -d "=" -f 2 -s)"
    SECURITY_PATCH_LEVEL="$(grep "^security_patch" <<< "$BUILD_INFO" | cut -d "=" -f 2 -s)"
    FINGERPRINT="$(grep "^source_fingerprint" <<< "$BUILD_INFO" | cut -d "=" -f 2 -s)"

    mkdir -p "$TMP_DIR/META-INF/com/android"

    # https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/tools/releasetools/ota_utils.py#259
    if [ -f "$PROTO_FILE" ]; then
        local MESSAGE

        MESSAGE+="type: BLOCK"
        MESSAGE+=", precondition: {device: \\\"$DEVICE\\\"}"
        MESSAGE+=", postcondition: {device: \\\"$DEVICE\\\""
        MESSAGE+=", build: \\\"$FINGERPRINT\\\""
        MESSAGE+=", build_incremental: \\\"$INCREMENTAL\\\""
        MESSAGE+=", timestamp: $TIMESTAMP"
        MESSAGE+=", sdk_level: \\\"$RELEASE\\\""
        MESSAGE+=", security_patch_level: \\\"$SECURITY_PATCH_LEVEL\\\"}"

        EVAL "protoc --encode=build.tools.releasetools.OtaMetadata --proto_path=\"$(dirname "$PROTO_FILE")\" \"$PROTO_FILE\" <<< \"$MESSAGE\" > \"$TMP_DIR/META-INF/com/android/metadata.pb\"" || exit 1
    fi

    # https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/tools/releasetools/ota_utils.py#317
    {
        echo "ota-required-cache=0"
        echo "ota-type=BLOCK"
        echo "post-build=$FINGERPRINT"
        echo "post-build-incremental=$INCREMENTAL"
        echo "post-sdk-level=$RELEASE"
        echo "post-security-patch-level=$SECURITY_PATCH_LEVEL"
        echo "post-timestamp=$TIMESTAMP"
        echo "pre-device=$DEVICE"
    } > "$TMP_DIR/META-INF/com/android/metadata"
}

GENERATE_OUTPUT_FILE()
{
    local FILE
    local SUFFIX
    local DEVICE

    DEVICE="$(grep "^device" <<< "$BUILD_INFO" | cut -d "=" -f 2 -s)"
    [ -z "$DEVICE" ] && DEVICE="$TARGET_CODENAME"
    SUFFIX="$(GET_PROP "system" "ro.build.PDA")"
    SUFFIX="${SUFFIX: -4}"

    local VER="${ROM_VERSION:-UN1CA_Carbon_IX_1.3}"
    VER="$(cut -d "-" -f 1 <<< "$VER")"
    FILE="$OUT_DIR/${VER}_${DEVICE}_${SUFFIX}.zip"

    echo "$FILE"
}

GENERATE_UPDATER_SCRIPT()
{
    local SCRIPT_FILE="$TMP_DIR/META-INF/com/google/android/updater-script"

    local PARTITION_COUNT=0

    [ -f "$TMP_DIR/vendor.transfer.list" ] && PARTITION_COUNT=$((PARTITION_COUNT + 1))
    [ -f "$TMP_DIR/product.transfer.list" ] && PARTITION_COUNT=$((PARTITION_COUNT + 1))
    [ -f "$TMP_DIR/system_ext.transfer.list" ] && PARTITION_COUNT=$((PARTITION_COUNT + 1))
    [ -f "$TMP_DIR/odm.transfer.list" ] && PARTITION_COUNT=$((PARTITION_COUNT + 1))
    [ -f "$TMP_DIR/vendor_dlkm.transfer.list" ] && PARTITION_COUNT=$((PARTITION_COUNT + 1))
    [ -f "$TMP_DIR/odm_dlkm.transfer.list" ] && PARTITION_COUNT=$((PARTITION_COUNT + 1))
    [ -f "$TMP_DIR/system_dlkm.transfer.list" ] && PARTITION_COUNT=$((PARTITION_COUNT + 1))

    {
        PRINT_ASSERTIONS "$BUILD_INFO" || exit 1

        PRINT_HEADER "$BUILD_INFO" || exit 1

        if $TARGET_USE_DYNAMIC_PARTITIONS; then
            # https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/tools/releasetools/common.py#4007
            echo -e "\n# --- Start patching dynamic partitions ---\n"
            echo -e "\n# Update dynamic partition metadata\n"
            echo -n 'assert(update_dynamic_partitions(package_extract_file("dynamic_partitions_op_list")'
            if [ -f "$TMP_DIR/unsparse_super_empty.img" ]; then
                # https://github.com/LineageOS/android_build/commit/98549f6893c3a93057e2d4cdd1015a93e9473b16
                # https://github.com/LineageOS/android_bootable_deprecated-ota/commit/e97be4333bd3824b8561c9637e9e6de28bc29da0
                echo -n ', package_extract_file("unsparse_super_empty.img")'
            fi
            echo    '));'
        fi
        for p in $PARTITIONS_LIST; do
            if [ ! -f "$TMP_DIR/$p.transfer.list" ]; then
                continue
            fi
            $TARGET_USE_DYNAMIC_PARTITIONS && echo -e "\n# Patch partition $p\n"
            echo -n 'ui_print("Patching '
            echo -n "$p image unconditionally..."
            echo    '");'
            if [[ "$p" == "system" ]]; then
                echo -n 'show_progress(0.'
                echo -n "$(bc -l <<< "9 - $PARTITION_COUNT")"
                echo    '00000, 0);'
            else
                echo    'show_progress(0.100000, 0);'
            fi
            echo -n "block_image_update("
            GET_DEVICE_FROM_MOUNTPOINT "/$p"
            echo -n ', package_extract_file("'
            echo -n "$p.transfer.list"
            echo -n '"), "'
            echo -n "$p.new.dat"
            [ -f "$TMP_DIR/$p.new.dat.br" ] && echo -n ".br"
            echo -n '", "'
            echo -n "$p.patch.dat"
            echo    '") ||'
            echo -n '  abort("'
            [[ "$p" == "system" ]] && echo -n "E1001" || echo -n "E2001"
            echo -n ": Failed to update $p image."
            echo    '");'
        done
        $TARGET_USE_DYNAMIC_PARTITIONS && echo -e "\n# --- End patching dynamic partitions ---\n"

        if [[ "$TARGET_CODENAME" == "dm1q" ]]; then
            if [ -f "$TMP_DIR/boot.img" ]; then
                echo    'ui_print("Flashing boot image (GoRhanHee Kernel)...");'
                echo    'package_extract_file("boot.img", "/dev/block/by-name/boot");'
            fi
            if [ -f "$TMP_DIR/vendor_boot.img" ]; then
                echo    'ui_print("Flashing vendor_boot image...");'
                echo    'package_extract_file("vendor_boot.img", "/dev/block/by-name/vendor_boot");'
            fi
            if [ -f "$TMP_DIR/recovery.img" ]; then
                echo    'ui_print("Flashing recovery image (TWRP)...");'
                echo    'package_extract_file("recovery.img", "/dev/block/by-name/recovery");'
            fi
            if [ -f "$TMP_DIR/KernelSU_Next.apk" ]; then
                echo    'ui_print("Extracting KernelSU-Next to /sdcard...");'
                echo    'package_extract_file("KernelSU_Next.apk", "/sdcard/KernelSU_Next.apk");'
            fi
        else
            for b in $KERNEL_BINS; do
                if [ -f "$TMP_DIR/$b.img" ]; then
                    echo -n 'ui_print("Full Patching '
                    echo -n "$b.img img..."
                    echo    '");'
                    echo -n 'package_extract_file("'
                    echo -n "$b.img"
                    echo -n '", '
                    GET_DEVICE_FROM_MOUNTPOINT "/$b"
                    echo    ");"
                fi
            done
            if [ -f "$TMP_DIR/boot.img" ]; then
                echo    'ui_print("Installing boot image...");'
                echo -n 'package_extract_file("boot.img", '
                GET_DEVICE_FROM_MOUNTPOINT "/boot"
                echo    ");"
            fi
        fi

        echo    'show_progress(0.100000, 10);'

        if [ -f "$SRC_DIR/target/$TARGET_CODENAME/installer/install-end.edify" ]; then
            cat "$SRC_DIR/target/$TARGET_CODENAME/installer/install-end.edify"
        fi

        echo    'set_progress(1.000000);'

        PRINT_SEPARATOR
        echo    'ui_print(" ");'
    } > "$SCRIPT_FILE"
}

GET_SUPER_GROUP_SIZE()
{
    local GROUP_NAME="$TARGET_SUPER_GROUP_NAME"
    GROUP_NAME="$(tr "[:lower:]" "[:upper:]" <<< "$TARGET_SUPER_GROUP_NAME")"

    local VAR="TARGET_${GROUP_NAME}_SIZE"

    _CHECK_NON_EMPTY_PARAM "$VAR" "${!VAR}" || exit 1

    echo "${!VAR}"
}
# ]

if [ "$#" != "0" ]; then
    echo "Usage: build_direct_flashable_zip" >&2
    exit 1
fi

[ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR/META-INF/com/google/android"
cp -a "$SRC_DIR/prebuilts/bootable/deprecated-ota/updater" "$TMP_DIR/META-INF/com/google/android/update-binary"

BUILD_INFO="$(GENERATE_BUILD_INFO)"
OUTPUT_FILE="$(GENERATE_OUTPUT_FILE)"

LOG_STEP_IN "- Building OS partitions (Parallel)"
while IFS= read -r f; do
    PARTITION=$(basename "$f")
    IS_VALID_PARTITION_NAME "$PARTITION" || continue

    (
        if $TARGET_USE_DYNAMIC_PARTITIONS; then
            "$SRC_DIR/scripts/build_fs_image.sh" "$TARGET_OS_FILE_SYSTEM_TYPE" \
                -o "$TMP_DIR/$PARTITION.img" -m -S \
                "$WORK_DIR/$PARTITION" "$WORK_DIR/configs/file_context-$PARTITION" "$WORK_DIR/configs/fs_config-$PARTITION" || exit 1
        else
            _GET_PARTITION_SIZE "$PARTITION" > /dev/null || exit 1

            "$SRC_DIR/scripts/build_fs_image.sh" "$TARGET_OS_FILE_SYSTEM_TYPE" \
                -o "$TMP_DIR/$PARTITION.img" -m -S -s "$(_GET_PARTITION_SIZE "$PARTITION")" \
                "$WORK_DIR/$PARTITION" "$WORK_DIR/configs/file_context-$PARTITION" "$WORK_DIR/configs/fs_config-$PARTITION" || exit 1
        fi
    ) &
done < <(find "$WORK_DIR" -maxdepth 1 -type d)
wait
LOG_STEP_OUT

if $TARGET_USE_DYNAMIC_PARTITIONS; then
    LOG "- Building unsparse_super_empty.img"
    BUILD_SUPER_EMPTY

    LOG "- Generating dynamic_partitions_op_list"
    GENERATE_OP_LIST
fi

for p in $PARTITIONS_LIST; do
    if [ ! -f "$TMP_DIR/$p.img" ]; then
        continue
    fi

    LOG "- Converting $p.img to $p.new.dat"
    EVAL "img2sdat -o \"$TMP_DIR\" --tgt-block-map \"$TMP_DIR/$p.map\" \"$TMP_DIR/$p.img\"" || exit 1
    rm -f "$TMP_DIR/$p.img" "$TMP_DIR/$p.map"

    if ! $DEBUG; then
        LOG "- Compressing $p.new.dat"
        EVAL "brotli --quality=6 --output=\"$TMP_DIR/$p.new.dat.br\" \"$TMP_DIR/$p.new.dat\"" || exit 1
        rm -f "$TMP_DIR/$p.new.dat"
    fi
done

if [ -d "$WORK_DIR/kernel" ]; then
    KERNEL_IMAGES="boot.img dt.img dtbo.img init_boot.img vendor_boot.img"

    for f in $KERNEL_IMAGES; do
        [ ! -f "$WORK_DIR/kernel/$f" ] && continue

        LOG_STEP_IN "- Copying $f"
        EVAL "cp -a \"$WORK_DIR/kernel/$f\" \"$TMP_DIR/$f\"" || exit 1
        if ! $TARGET_DISABLE_AVB_SIGNING; then
            SIGN_IMAGE_WITH_AVB "$TMP_DIR/$f" || exit 1
        fi
        LOG_STEP_OUT
    done
fi

if [ -f "$SRC_DIR/carbon_ours/recovery_twrp/recovery.img" ]; then
    LOG "- Including TWRP recovery.img in package"
    cp -a "$SRC_DIR/carbon_ours/recovery_twrp/recovery.img" "$TMP_DIR/recovery.img"
elif [ -f "$SRC_DIR/carbon_ours/recovery_twrp/recovery.img.00" ]; then
    LOG "- Rebuilding TWRP recovery.img from split parts"
    cat "$SRC_DIR/carbon_ours/recovery_twrp/recovery.img."[0-9][0-9] > "$TMP_DIR/recovery.img"
fi

if [ -f "$SRC_DIR/carbon_ours/prebuilt_apps/KernelSU_Next.apk" ]; then
    LOG "- Including official KernelSU_Next.apk in package"
    cp -a "$SRC_DIR/carbon_ours/prebuilt_apps/KernelSU_Next.apk" "$TMP_DIR/KernelSU_Next.apk"
fi

LOG "- Generating updater-script"
GENERATE_UPDATER_SCRIPT

LOG "- Generating build_info.txt"
PRINT_BUILD_INFO "$BUILD_INFO" > "$TMP_DIR/build_info.txt" || exit 1

LOG "- Generating OTA metadata"
GENERATE_OTA_METADATA

if [ -d "$SRC_DIR/target/$TARGET_CODENAME/installer/root" ]; then
    LOG "- Copying target custom install files"
    rsync -a --exclude='*.bak' --exclude='*.bak.*' --exclude='/unica/tee-simulator' -- "$SRC_DIR/target/$TARGET_CODENAME/installer/root/" "$TMP_DIR/" || exit 1
fi

if [ -f "$SRC_DIR/target/$TARGET_CODENAME/installer/customize.sh" ]; then
    LOG_STEP_IN "- Running target custom install script"
    (
    . "$SRC_DIR/target/$TARGET_CODENAME/installer/customize.sh"
    ) || exit 1
    LOG_STEP_OUT
fi

python3 "$SRC_DIR/scripts/internal/rom_payload.py" quarantine "$TMP_DIR" || exit 1

LOG "- Creating zip"
EVAL "rm -f \"$TMP_DIR/rom.zip\"" || exit 1
# For S23U TWRP compatible
EVAL "cd \"$TMP_DIR\" && 7z a -tzip -mx=1 -mmt=$(nproc) \"$TMP_DIR/rom.zip\" -r * -x!rom.zip -xr!*.bak -xr!*.bak.*" || exit 1

if ! $DEBUG || $ROM_IS_OFFICIAL; then
    LOG "- Signing zip"
    EVAL "signapk -w \"$PUBLIC_KEY_PATH\" \"$PRIVATE_KEY_PATH\" \"$TMP_DIR/rom.zip\" \"$OUTPUT_FILE\"" || exit 1
    rm -f "$TMP_DIR/rom.zip"
else
    mv -f "$TMP_DIR/rom.zip" "$OUTPUT_FILE"
fi

exit 0
