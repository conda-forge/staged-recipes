build_install_qemu() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("${@:-}")

  export PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"
  export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig"
  export PKG_CONFIG_LIBDIR="${BUILD_PREFIX}/lib/pkgconfig"

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      --enable-strip

    ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1
    # ninja check > "${SRC_DIR}"/_check.log 2>&1
    ninja install > "${SRC_DIR}"/_install.log 2>&1
  popd || exit 1
}

build_install_qemu_win() {
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
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      --enable-strip

    sed -i 's#\(windres\|nm\|windmc\)\b#\1.exe#g' build.ninja
    sed -i 's#D__[^ ]*_qapi_#qapi_#g' build.ninja
    touch config-meson.cross ../meson.build build.ninja config.status meson-info/intro-targets.json

    PYTHON_WIN="${build_dir}/pyvenv/Scripts/python.exe"
    PYTHON_WIN=$(echo "${PYTHON_WIN}" | sed 's|^\([a-zA-Z]\):|/\L\1|g')
    export PYTHON_WIN

    MSYS2_ARG_CONV_EXCL="*" ninja -j"${CPU_COUNT}"
    # ninja check > "${SRC_DIR}"/_check.log 2>&1
    ninja install
  popd || exit 1
}
