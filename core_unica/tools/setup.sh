#!/usr/bin/env bash
# NPL toolchain bootstrap (UN1CA layout under out/tools).
# One entry: host packages (any common Linux) → submodules → build_dependencies → fast-path leftovers.
# Skip host packages with: SKIP_HOST_PACKAGES=1 ./tools/setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_TOOLS="$PROJECT_ROOT/out/tools"
BIN_DIR="$OUT_TOOLS/bin"
LIB_DIR="$OUT_TOOLS/lib"
VENV_DIR="$OUT_TOOLS/venv"
APKTOOL_VERSION="3.0.2"

_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null; then
    sudo "$@"
  else
    echo "[!] Need root (or sudo) to install: $*" >&2
    return 1
  fi
}

detect_pm() {
  if command -v dnf >/dev/null; then echo dnf
  elif command -v apt-get >/dev/null; then echo apt-get
  elif command -v apt >/dev/null; then echo apt
  elif command -v pacman >/dev/null; then echo pacman
  elif command -v zypper >/dev/null; then echo zypper
  elif command -v yum >/dev/null; then echo yum
  else echo ""
  fi
}

host_pkgs_needed() {
  # Return 0 if android-tools cmake deps (or general UN1CA cmds) are missing
  local cmd pc
  for cmd in java clang cmake make git curl unzip python3 pkg-config protoc rsync jq xxd lz4 7z bc ffmpeg cwebp getfattr ld.lld; do
    command -v "$cmd" >/dev/null || return 0
  done
  command -v pkg-config >/dev/null || return 0
  for pc in liblz4 libbrotlicommon libbrotlidec libbrotlienc libpcre2-8 libzstd zlib; do
    pkg-config --exists "$pc" 2>/dev/null || return 0
  done
  [ -f /usr/include/gtest/gtest_prod.h ] || [ -f /usr/src/googletest/googletest/include/gtest/gtest_prod.h ] || \
    [ -f "$SCRIPT_DIR/include/gtest/gtest_prod.h" ] || return 0
  # erofs-utils links -static; Fedora splits these into glibc-static / libstdc++-static
  { [ -f /usr/lib64/libc.a ] || [ -f /usr/lib/libc.a ] || [ -f /usr/lib/x86_64-linux-gnu/libc.a ]; } || return 0
  local _stdcpp
  _stdcpp="$(gcc -print-file-name=libstdc++.a 2>/dev/null || true)"
  [ -n "$_stdcpp" ] && [ -f "$_stdcpp" ] || return 0
  return 1
}

install_host_packages() {
  local PM
  PM="$(detect_pm)"
  if [ -z "$PM" ]; then
    echo "[!] Unknown distro — install clang cmake java git lz4-devel brotli-devel pcre2-devel libzstd-devel protobuf yourself."
    return 1
  fi

  echo "[>] Installing host packages with $PM (sudo if needed)..."
  case "$PM" in
    dnf|yum)
      _sudo "$PM" install -y \
        java-latest-openjdk java-latest-openjdk-devel \
        vim-common curl unzip lz4 python3 python3-pip python3-virtualenv \
        rsync jq p7zip bc clang cmake make git ffmpeg libwebp-tools \
        protobuf-compiler protobuf-devel attr pkgconf-pkg-config \
        lz4-devel brotli-devel zlib-devel pcre2-devel libzstd-devel bzip2-devel \
        gtest-devel lld glibc-static libstdc++-static gcc-c++ \
        file zip zstd perl brotli
      ;;
    apt-get|apt)
      _sudo "$PM" update -y || true
      _sudo "$PM" install -y \
        openjdk-17-jdk xxd curl unzip lz4 python3 python3-pip python3-venv \
        rsync jq p7zip-full bc clang cmake make git ffmpeg webp \
        protobuf-compiler libprotobuf-dev attr pkg-config \
        liblz4-dev libbrotli-dev zlib1g-dev libpcre2-dev libzstd-dev libbz2-dev \
        libgtest-dev lld g++ libc6-dev \
        file zip zstd perl brotli
      ;;
    pacman)
      _sudo pacman -Sy --noconfirm --needed \
        jdk-openjdk vim curl unzip lz4 python python-pip python-virtualenv \
        rsync jq p7zip bc clang cmake make git ffmpeg libwebp \
        protobuf attr pkgconf pcre2 zstd bzip2 zlib brotli gtest lld gcc \
        glibc fuse3 file zip perl
      ;;
    zypper)
      _sudo zypper install -y \
        java-17-openjdk-devel vim curl unzip lz4 python3 python3-pip python3-virtualenv \
        rsync jq p7zip bc clang cmake make git ffmpeg libwebp-tools \
        protobuf-devel pkg-config liblz4-devel libbrotli-devel zlib-devel \
        pcre2-devel libzstd-devel libbz2-devel gtest lld gcc-c++ glibc-devel-static libstdc++-devel \
        attr file zip zstd perl brotli
      ;;
  esac
}

echo "=========================================="
echo " Setting up NPL ROM Builder Toolchain..."
echo " (host packages + out/tools — same as UN1CA)"
echo "=========================================="

mkdir -p "$BIN_DIR" "$LIB_DIR"

if [ "${SKIP_HOST_PACKAGES:-0}" != "1" ]; then
  if host_pkgs_needed; then
    install_host_packages || echo "[!] Host package install failed — cmake may still fail."
  else
    echo "[✓] Host packages already present"
  fi
else
  echo "[>] SKIP_HOST_PACKAGES=1 — not installing distro packages"
fi

if git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[>] git submodule update --init --recursive"
  git -C "$PROJECT_ROOT" submodule update --init --recursive || \
    echo "[!] submodule update failed — continuing"
fi

export SRC_DIR="${SRC_DIR:-$PROJECT_ROOT}"
export OUT_DIR="${OUT_DIR:-$PROJECT_ROOT/out}"
export TOOLS_DIR="${TOOLS_DIR:-$OUT_TOOLS}"
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  export PATH="$BIN_DIR:$PATH"
fi

# zip_writer.h includes <gtest/gtest_prod.h> — use bundled stub + boringssl googletest
GTEST_INCS="$SCRIPT_DIR/include"
_BSSL_GTEST="$PROJECT_ROOT/external/android-tools/vendor/boringssl/third_party/googletest/googletest/include"
[ -d "$_BSSL_GTEST" ] && GTEST_INCS="$GTEST_INCS:$_BSSL_GTEST"
export CPLUS_INCLUDE_PATH="$GTEST_INCS${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}"
export C_INCLUDE_PATH="$GTEST_INCS${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}"
export CXXFLAGS="-I$SCRIPT_DIR/include ${CXXFLAGS:-}"
export CMAKE_CXX_FLAGS="-I$SCRIPT_DIR/include ${CMAKE_CXX_FLAGS:-}"

# clang+lld -static looks for -lc/-lm/-lstdc++ via LIBRARY_PATH
_gcc_lib="$(dirname "$(gcc -print-file-name=libgcc.a 2>/dev/null || true)")"
export LIBRARY_PATH="/usr/lib64:/usr/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/aarch64-linux-gnu${_gcc_lib:+:$_gcc_lib}${LIBRARY_PATH:+:$LIBRARY_PATH}"
unset _gcc_lib

if [ -f "$PROJECT_ROOT/scripts/build_dependencies.sh" ]; then
  if [ -f "$PROJECT_ROOT/external/android-tools/CMakeLists.txt" ]; then
    echo "[>] Building UN1CA tools (android-tools / apktool / erofs / …)..."
    # Stale cmake cache from a failed gtest-less configure
    if [ -d "$PROJECT_ROOT/external/android-tools/build" ] && [ ! -x "$BIN_DIR/mke2fs.android" ]; then
      rm -rf "$PROJECT_ROOT/external/android-tools/build"
    fi
    if [ -d "$PROJECT_ROOT/external/erofs-utils/out" ] && \
       [ ! -x "$PROJECT_ROOT/external/erofs-utils/out/erofs-tools/fuse.erofs" ]; then
      rm -rf "$PROJECT_ROOT/external/erofs-utils/out"
    fi
    if ! bash "$PROJECT_ROOT/scripts/build_dependencies.sh"; then
      echo "[!] build_dependencies failed; continuing with fast-path tools."
    fi
  else
    echo "[!] external/android-tools not initialized — fast-path only"
  fi
fi

need_apktool=false
if [ ! -f "$BIN_DIR/apktool" ] || [ ! -f "$BIN_DIR/apktool.jar" ]; then
  need_apktool=true
elif ! "$BIN_DIR/apktool" b --help 2>&1 | grep -q 'shorten-res-paths'; then
  echo "[!] apktool in $BIN_DIR is stock (no -srp). UN1CA needs the patched build."
  if [ -x "$PROJECT_ROOT/external/apktool/gradlew" ]; then
    echo "[>] Building patched apktool from external/apktool..."
    # shellcheck source=/dev/null
    source "$PROJECT_ROOT/tools/ensure_build_jdk.sh"
    (
      cd "$PROJECT_ROOT/external/apktool"
      git reset --hard
      git apply "$PROJECT_ROOT/external/patches/apktool/0001-feat-support-aapt-optimization.patch"
      ./gradlew shadowJar -x test --no-daemon
    )
    cp -a "$PROJECT_ROOT/external/apktool/scripts/linux/apktool" "$BIN_DIR/apktool"
    cp -a "$PROJECT_ROOT/external/apktool/brut.apktool/apktool-cli/build/libs/apktool-cli.jar" "$BIN_DIR/apktool.jar"
    chmod +x "$BIN_DIR/apktool"
    need_apktool=false
  else
    need_apktool=true
  fi
fi

if $need_apktool; then
  echo "[>] Downloading apktool ${APKTOOL_VERSION} into $BIN_DIR..."
  curl -fsSL "https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool" -o "$BIN_DIR/apktool"
  curl -fsSL "https://github.com/iBotPeaches/Apktool/releases/download/v${APKTOOL_VERSION}/apktool_${APKTOOL_VERSION}.jar" -o "$BIN_DIR/apktool.jar"
  chmod +x "$BIN_DIR/apktool"
  echo "[✓] apktool ${APKTOOL_VERSION} installed"
else
  echo "[✓] apktool 3.x already in $BIN_DIR"
fi

if [ ! -e "$BIN_DIR/mkuserimg_mke2fs" ]; then
  if [ -f "$PROJECT_ROOT/external/ext4_utils/mkuserimg_mke2fs.py" ]; then
    cp -a "$PROJECT_ROOT/external/ext4_utils/mkuserimg_mke2fs.py" "$BIN_DIR/mkuserimg_mke2fs.py"
    ln -sfn "$BIN_DIR/mkuserimg_mke2fs.py" "$BIN_DIR/mkuserimg_mke2fs"
    [ -f "$PROJECT_ROOT/external/ext4_utils/mke2fs.conf" ] && \
      cp -a "$PROJECT_ROOT/external/ext4_utils/mke2fs.conf" "$BIN_DIR/mke2fs.conf"
    echo "[✓] mkuserimg_mke2fs wrapper installed"
  fi
else
  echo "[✓] mkuserimg_mke2fs already present"
fi

if ! command -v zipalign &>/dev/null && [ ! -f "$BIN_DIR/zipalign" ]; then
  echo "[>] Downloading zipalign..."
  curl -fsSL "https://android.googlesource.com/platform/prebuilts/sdk/+/refs/heads/main/tools/linux/bin/zipalign?format=TEXT" | base64 -d > "$BIN_DIR/zipalign"
  mkdir -p "$LIB_DIR" "$OUT_TOOLS/lib64"
  curl -fsSL "https://android.googlesource.com/platform/prebuilts/sdk/+/refs/heads/main/tools/linux/lib64/libc++.so?format=TEXT" | base64 -d > "$OUT_TOOLS/lib64/libc++.so" || true
  cp -a "$OUT_TOOLS/lib64/libc++.so" "$LIB_DIR/libc++.so" || true
  cp -a "$OUT_TOOLS/lib64/libc++.so" "$BIN_DIR/libc++.so" || true
  chmod +x "$BIN_DIR/zipalign"
  echo "[✓] zipalign installed"
fi

# Gradle auto-picks /usr/lib/jvm/java-*-openjdk JRE (no javac) on Fedora.
# Prefer the SDK that actually has a compiler.
if [ ! -x "${JAVA_HOME:-}/bin/javac" ]; then
  for _jdk in /usr/lib/jvm/java /usr/lib/jvm/java-latest-openjdk /usr/lib/jvm/java-21-openjdk /usr/lib/jvm/java-17-openjdk; do
    if [ -x "$_jdk/bin/javac" ]; then
      export JAVA_HOME="$_jdk"
      export PATH="$JAVA_HOME/bin:$PATH"
      break
    fi
  done
  unset _jdk
fi

# AOSP prebuilt signapk.jar (~3MB) needs conscrypt JNI and crashes at APEX
# sign. UN1CA's shadow fat jar (~18MB) bundles the native bits.
_signapk_ok() {
  [ -f "$BIN_DIR/signapk" ] && [ -f "$BIN_DIR/signapk.jar" ] || return 1
  [ "$(stat -c%s "$BIN_DIR/signapk.jar" 2>/dev/null || echo 0)" -gt 8000000 ] || return 1
  grep -q "Xmx1024M" "$BIN_DIR/signapk" 2>/dev/null || return 1
}
if ! _signapk_ok; then
  if [ -x "$PROJECT_ROOT/external/signapk/gradlew" ]; then
    echo "[>] Building signapk from external/signapk (UN1CA fat jar, Java 21 bytecode)..."
    # shellcheck source=/dev/null
    source "$PROJECT_ROOT/tools/ensure_build_jdk.sh"
    (cd "$PROJECT_ROOT/external/signapk" && ./gradlew build --no-daemon \
      --init-script "$PROJECT_ROOT/tools/signapk-release21.init.gradle")
    cp -a "$PROJECT_ROOT/tools/signapk" "$BIN_DIR/signapk"
    cp -a "$PROJECT_ROOT/external/signapk/signapk/build/libs/signapk-all.jar" "$BIN_DIR/signapk.jar"
    chmod +x "$BIN_DIR/signapk"
  fi
  if ! _signapk_ok; then
    echo "[!] signapk is missing or is the AOSP stub (conscrypt JNI). Bluetooth APEX signing will fail."
    echo "    Fix: JAVA_HOME must have javac, then: cd external/signapk && ./gradlew build"
  else
    echo "[✓] signapk installed (UN1CA fat jar)"
  fi
else
  echo "[✓] signapk already works"
fi
unset -f _signapk_ok

_is_real_elf() { file "$1" 2>/dev/null | grep -q "ELF"; }
if ! _is_real_elf "$BIN_DIR/fsck.erofs" || ! _is_real_elf "$BIN_DIR/mkfs.erofs"; then
  echo "[>] Downloading erofs-utils..."
  _EROFS_URL="$(curl -fsSL "https://api.github.com/repos/sekaiacg/erofs-tools/releases/latest" | \
    python3 -c "import sys,json; r=json.load(sys.stdin); \
    [print(a['browser_download_url']) for a in r.get('assets',[]) \
    if 'Linux_x86_64' in a['name']]" 2>/dev/null | head -1)"
  if [ -n "${_EROFS_URL:-}" ]; then
    curl -fsSL "$_EROFS_URL" -o /tmp/_erofs_utils.zip
    rm -rf /tmp/_erofs_utils
    mkdir -p /tmp/_erofs_utils
    unzip -o /tmp/_erofs_utils.zip -d /tmp/_erofs_utils/ >/dev/null
    for _bin in fsck.erofs mkfs.erofs dump.erofs extract.erofs; do
      [ -f "/tmp/_erofs_utils/$_bin" ] && cp "/tmp/_erofs_utils/$_bin" "$BIN_DIR/$_bin" && chmod +x "$BIN_DIR/$_bin"
    done
    rm -rf /tmp/_erofs_utils.zip /tmp/_erofs_utils
    echo "[✓] erofs-utils installed"
  fi
  unset _EROFS_URL _bin
else
  echo "[✓] erofs-utils already installed"
fi
unset -f _is_real_elf

if [ ! -d "$VENV_DIR" ]; then
  echo "[>] Creating Python venv..."
  python3 -m venv "$VENV_DIR" 2>/dev/null || true
fi
if [ -f "$VENV_DIR/bin/pip" ]; then
  "$VENV_DIR/bin/pip" install -q "git+https://github.com/ananjaser1211/samloader.git" >/dev/null 2>&1 || true
  [ -f "$VENV_DIR/bin/samloader" ] && ln -sfn "$VENV_DIR/bin/samloader" "$BIN_DIR/samloader"
fi
[ -f "$BIN_DIR/samloader" ] && echo "[✓] samloader at $BIN_DIR/samloader"

if [ -x "$BIN_DIR/mke2fs.android" ]; then
  echo "[✓] mke2fs.android (android-tools built)"
else
  echo "[!] mke2fs.android missing — APEX/ext4 rebuilds will fail until build_dependencies succeeds"
fi

echo "=========================================="
echo " Toolchain setup completed!"
echo " PATH should include: $BIN_DIR"
echo "=========================================="
