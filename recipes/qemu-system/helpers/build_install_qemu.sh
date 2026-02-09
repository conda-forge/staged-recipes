build_install_qemu() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("${@:-}")

  export PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"
  export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig"

  # Platform-specific configure flags
  local platform_args=()
  if [[ "${target_platform}" == osx-* ]]; then
    # Disable apple-gfx (pvg) - requires macOS 12+ SDK
    platform_args+=(--disable-pvg)
  fi

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1
    # Let configure auto-detect most features
    # Only specify what we explicitly want to control
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      "${platform_args[@]}" \
      --enable-strip

    ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1 || { cat "${SRC_DIR}"/_make.log; exit 1; }
    # ninja check > "${SRC_DIR}"/_check.log 2>&1
    ninja install > "${SRC_DIR}"/_install.log 2>&1
  popd || exit 1
}

build_install_qemu_non_unix() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("${@:-}")

  local _pkg_config="$(which pkg-config | sed 's|^/\(.\)|\1:|g' | sed 's|/|\\|g')"
  local _pkg_config_path="$(echo ${PREFIX}/Library/lib/pkgconfig | sed 's|^/\(.\)|\1:|g' | sed 's|/|\\|g')"
  export PKG_CONFIG="${_pkg_config}"
  export PKG_CONFIG_PATH="${_pkg_config_path}"
  export PKG_CONFIG_LIBDIR="${PKG_CONFIG_PATH}"

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1
    # Pre-create pyvenv with access to conda's site-packages (has meson)
    python -m venv --system-site-packages pyvenv
    # Install pycotap from QEMU's vendored wheels (CI is network-isolated)
    ./pyvenv/Scripts/pip install --no-index --find-links="${_SRC_DIR_}/qemu_source/python/wheels" pycotap

    # Now configure will find existing pyvenv with meson
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      --enable-strip

    sed -i 's#\(windres\|nm\|windmc\)\b#\1.exe#g' build.ninja
    sed -i 's#D__[^ ]*_qapi_#qapi_#g' build.ninja

    MSYS2_ARG_CONV_EXCL="*" ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1 || { cat "${SRC_DIR}"/_make.log; exit 1; }
    ninja install
  popd || exit 1
}
