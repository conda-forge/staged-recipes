#!/usr/bin/env bash
# Main QEMU build orchestration
# Sources modular helpers for specific functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/windows_workarounds.sh"

# Build and install QEMU for Unix platforms (Linux, macOS)
# Usage: build_install_qemu <build_dir> <install_dir> [configure_args...]
build_install_qemu() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("${@:-}")

  # Set up pkg-config
  export PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"
  export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig"

  # Platform-specific configure flags
  local platform_args=()
  local strip_arg="--enable-strip"
  if [[ "${target_platform}" == osx-* ]]; then
    platform_args+=(--disable-pvg)  # Requires macOS 12+ SDK
    platform_args+=(--disable-hvf)  # HVF entitlement script requires Rez (not in modern SDK)
    strip_arg="--disable-strip"     # Strip conflicts with code signing on macOS
  fi

  rm -rf "${build_dir}"
  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1

    # Configure
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      --disable-download \
      "${qemu_args[@]}" \
      "${platform_args[@]}" \
      ${strip_arg} > "${SRC_DIR}"/_configure.log 2>&1 || { cat "${SRC_DIR}"/_configure.log; exit 1; }

    # Build and install
    ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1 || { cat "${SRC_DIR}"/_make.log; exit 1; }
      # macOS: QEMU's entitlement.sh calls Rez which uses xcodebuild to find tools.
      # The Rez wrapper derives SDK path from MACOSX_DEPLOYMENT_TARGET (11.0) but
      # that SDK doesn't exist in modern Xcode (16.4 requires minimum SDK 14.0).
      # Workaround: temporarily unset both MACOSX_DEPLOYMENT_TARGET and SDKROOT
      # to let xcrun find the current Xcode SDK, then restore them.
      if [[ "${target_platform}" == osx-* ]]; then
        _saved_deployment_target="${MACOSX_DEPLOYMENT_TARGET:-}"
        _saved_sdkroot="${SDKROOT:-}"
        unset MACOSX_DEPLOYMENT_TARGET
        unset SDKROOT
        export SDKROOT="$(xcrun --show-sdk-path)"
        ninja install > "${SRC_DIR}"/_install.log 2>&1 || { cat "${SRC_DIR}"/_install.log; exit 1; }
        if [[ -n "${_saved_deployment_target}" ]]; then
          export MACOSX_DEPLOYMENT_TARGET="${_saved_deployment_target}"
        fi
        if [[ -n "${_saved_sdkroot}" ]]; then
          export SDKROOT="${_saved_sdkroot}"
        fi
      else
        ninja install > "${SRC_DIR}"/_install.log 2>&1 || { cat "${SRC_DIR}"/_install.log; exit 1; }
      fi

    # macOS: Strip extended attributes before codesigning
    if [[ "${target_platform}" == osx-* ]]; then
      xattr -cr "${install_dir}"
    fi

    # Clean up QEMU meson build artifacts that shouldn't be installed
    rm -f "${install_dir}/bin/"*-unsigned 2>/dev/null || true

  popd || exit 1
}

# Build and install QEMU for Windows (MSYS2/MinGW)
# Usage: build_install_qemu_non_unix <build_dir> <install_dir> [configure_args...]
build_install_qemu_non_unix() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("${@:-}")

  # Set up pkg-config with Windows paths
  # Hardcode the path instead of relying on `which pkg-config`: PATH in this
  # build environment doesn't include ${BUILD_PREFIX}/Library/bin, so a PATH
  # lookup fails (mirrors the Unix branch's hardcoded PKG_CONFIG above).
  local _pkg_config="$(echo ${BUILD_PREFIX}/Library/bin/pkg-config.exe | sed 's|^/\(.\)|\1:|g' | sed 's|/|\\|g')"
  local _pkg_config_path="$(echo ${PREFIX}/Library/lib/pkgconfig | sed 's|^/\(.\)|\1:|g' | sed 's|/|\\|g')"
  export PKG_CONFIG="${_pkg_config}"
  export PKG_CONFIG_PATH="${_pkg_config_path}"
  export PKG_CONFIG_LIBDIR="${PKG_CONFIG_PATH}"

  # Ensure the mingw compiler toolchain is on PATH: QEMU's configure runs a
  # compiler check for x86_64-w64-mingw32-gcc.exe, which lives under
  # ${BUILD_PREFIX}/Library/mingw-w64/bin and is not on PATH by default here.
  export PATH="${BUILD_PREFIX}/Library/mingw-w64/bin:${BUILD_PREFIX}/Library/bin:${PATH}"

  rm -rf "${build_dir}"
  mkdir -p "${build_dir}"

  # Windows-specific pre-configure setup
  setup_windows_build_env "${build_dir}" "${SRC_DIR}/qemu_source"

  pushd "${build_dir}" || exit 1

    # DEBUG (temporary, CI investigation only): show which "meson" bash's
    # PATH lookup resolves to right before configure runs its internal
    # `meson setup` invocation.
    echo "DEBUG: which meson (before configure) -> $(command -v meson 2>/dev/null || echo not-found)"

    # Configure
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      --disable-download \
      "${qemu_args[@]}" \
      --enable-strip > "${SRC_DIR}"/_configure.log 2>&1 || { cat "${SRC_DIR}"/_configure.log; exit 1; }

    # DEBUG (temporary, CI investigation only): unconditionally show
    # CONDA-DEBUG diagnostics written by the configure patch, since they
    # would otherwise be silently swallowed inside _configure.log (which
    # is only cat'd on configure FAILURE, not on success).
    echo "DEBUG: contents of _conda_debug.log (if any):"
    cat "${SRC_DIR}/_conda_debug.log" 2>/dev/null || echo "DEBUG: _conda_debug.log not found or empty"

    # DEBUG (temporary, CI investigation only): show which "meson" resolves
    # to after configure, and what command(s) meson baked into build.ninja
    # for the config-poison custom target -- this reveals exactly which
    # meson path/wrapper ninja will later try to CreateProcess directly.
    echo "DEBUG: which meson (after configure) -> $(command -v meson 2>/dev/null || echo not-found)"
    echo "DEBUG: build.ninja config-poison related line(s):"
    grep -E "config-poison|--internal exe|make-config-poison" build.ninja 2>/dev/null || true

    # Force meson's implicit self-regeneration of build.ninja (its
    # REGENERATE_BUILD ninja edge) to run and complete now, BEFORE we patch
    # build.ninja below -- otherwise the first real `ninja` invocation later
    # triggers this same regen internally and silently overwrites our sed
    # fix with a freshly-regenerated, unpatched build.ninja.
    MSYS2_ARG_CONV_EXCL="*" ninja build.ninja > "${SRC_DIR}"/_regen.log 2>&1 || { cat "${SRC_DIR}"/_regen.log; exit 1; }

    # Apply Windows build.ninja fixes
    patch_windows_build_ninja "${build_dir}"

    # Build and install
    MSYS2_ARG_CONV_EXCL="*" ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1 || { cat "${SRC_DIR}"/_make.log; exit 1; }
      ninja install

  popd || exit 1
}
