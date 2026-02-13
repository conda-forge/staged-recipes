#!/usr/bin/env bash
# Main QEMU build orchestration
# Sources modular helpers for specific functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/selective_tools.sh"
source "${SCRIPT_DIR}/windows_workarounds.sh"

# Install shared data files (keymaps, firmware, etc.)
install_qemu_datafiles() {
  local build_dir=$1
  local install_dir=$2

  pushd "${build_dir}" || return 1
    meson install --destdir="${install_dir}" --no-rebuild 2>/dev/null || ninja install
  popd || return 1
}

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
  if [[ "${target_platform}" == osx-* ]]; then
    platform_args+=(--disable-pvg)  # Requires macOS 12+ SDK
  fi

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1

    # Configure
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      "${platform_args[@]}" \
      --enable-strip > "${SRC_DIR}"/_configure.log 2>&1 || { cat "${SRC_DIR}"/_configure.log; exit 1; }

    # Build and install
    if [[ -n "${CONDA_QEMU_TOOLS:-}" ]]; then
      build_selective_tools "${build_dir}" "${install_dir}" "false"
    else
      ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1 || { cat "${SRC_DIR}"/_make.log; exit 1; }
      ninja install > "${SRC_DIR}"/_install.log 2>&1
    fi

    # macOS: Strip extended attributes before codesigning
    if [[ "${target_platform}" == osx-* ]]; then
      xattr -cr "${install_dir}"
    fi

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
  local _pkg_config="$(which pkg-config | sed 's|^/\(.\)|\1:|g' | sed 's|/|\\|g')"
  local _pkg_config_path="$(echo ${PREFIX}/Library/lib/pkgconfig | sed 's|^/\(.\)|\1:|g' | sed 's|/|\\|g')"
  export PKG_CONFIG="${_pkg_config}"
  export PKG_CONFIG_PATH="${_pkg_config_path}"
  export PKG_CONFIG_LIBDIR="${PKG_CONFIG_PATH}"

  mkdir -p "${build_dir}"

  # Windows-specific pre-configure setup
  setup_windows_build_env "${build_dir}" "${SRC_DIR}/qemu_source"

  pushd "${build_dir}" || exit 1

    # Configure
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      --enable-strip > "${SRC_DIR}"/_configure.log 2>&1 || { cat "${SRC_DIR}"/_configure.log; exit 1; }

    # Apply Windows build.ninja fixes
    patch_windows_build_ninja "${build_dir}"

    # Build and install
    if [[ -n "${CONDA_QEMU_TOOLS:-}" ]]; then
      build_selective_tools "${build_dir}" "${install_dir}" "true"
    else
      MSYS2_ARG_CONV_EXCL="*" ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1 || { cat "${SRC_DIR}"/_make.log; exit 1; }
      ninja install
    fi

  popd || exit 1
}
