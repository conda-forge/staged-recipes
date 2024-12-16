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
      --enable-user \
      --enable-strip \
      > "${SRC_DIR}"/_configure.log 2>&1

    ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1
    # ninja check > "${SRC_DIR}"/_check.log 2>&1
    ninja install > "${SRC_DIR}"/_install.log 2>&1
  popd || exit 1
}
