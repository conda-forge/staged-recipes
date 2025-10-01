build_osx_qemu() {
  local build_dir=${1:-"${SRC_DIR}"/_conda-build}
  local install_dir=${2:-"${PREFIX}"}

  git clone https://gitlab.freedesktop.org/slirp/libslirp.git
  pushd libslirp || exit 1
    meson build --prefix="${install_dir}"
    ninja -C build install
  popd || exit 1

  qemu_args=(
    "--disable-attr"
    "--target-list=aarch64-softmmu"
    "--enable-hvf"
    "--enable-slirp"
    "--enable-tools"
    "--enable-virtfs"
    "--enable-vhost-user"
  )
    #"--enable-guest-agent"  # Not supported
    #"--extra-cflags=-maxv2"  # Makes compilation fail

  export PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"
  export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig"
  export PKG_CONFIG_LIBDIR="${BUILD_PREFIX}/lib/pkgconfig"

  _configure_qemu "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"
  _build_qemu "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"
}

build_win_qemu() {
  local build_dir=${1:-"${SRC_DIR}"/_conda_build}
  local install_dir=${2:-"${PREFIX}"}

  qemu_args=(
    "--datadir=share/qemu"
    "--disable-attr"
    "--target-list=aarch64-softmmu"
    "--enable-tools"
    "--enable-guest-agent"
    "--disable-install-blobs"
  )

  local _pkg_config="$(which pkg-config | sed 's|^/\(.\)|\1:|g' | sed 's|/|\\|g')"
  local _pkg_config_path="$(echo ${PREFIX}/Library/lib/pkgconfig | sed 's|^/\(.\)|\1:|g' | sed 's|/|\\|g')"
  export PKG_CONFIG="${_pkg_config}"
  export PKG_CONFIG_PATH="${_pkg_config_path}"
  export PKG_CONFIG_LIBDIR="${PKG_CONFIG_PATH}"

  _configure_qemu "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"

  pushd "${build_dir}" || exit 1
    sed -i 's#\(windres\|nm\|windmc\)\b#\1.exe#g' build.ninja
    sed -i 's#D__[^ ]*aarch64_qapi_##g' build.ninja
    touch config-meson.cross ../meson.build build.ninja config.status meson-info/intro-targets.json
  popd || exit 1

  PYTHON_WIN="${build_dir}/pyvenv/Scripts/python.exe"
  PYTHON_WIN=$(echo "${PYTHON_WIN}" | sed 's|^\([a-zA-Z]\):|/\L\1|g')
  export PYTHON_WIN

  _build_qemu "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"
}

_configure_qemu() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("${@:-}")

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1
    "${SRC_DIR}"/qemu_source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      --enable-strip \
      --disable-docs

      if [[ "${target_platform}" == "linux-"* ]]; then
        # Using rattler-build does not create correct links (??)
        pushd ${SRC_DIR}/qemu_source/subprojects/libvhost-user/standard-headers
          rm -rf linux && ln -s ../../../include/standard-headers/linux linux
        popd
        pushd ${SRC_DIR}/qemu_source/subprojects/libvduse/linux-headers
          rm -rf linux && ln -s ../../../linux-headers/linux linux
        popd
        pushd ${SRC_DIR}/qemu_source/subprojects/libvduse/standard-headers
          rm -rf linux && ln -s ../../../include/standard-headers/linux linux
        popd
        pushd ${SRC_DIR}/qemu_source/subprojects/libvduse/standard-headers
          rm -rf linux && ln -s ../../../include/standard-headers/linux linux
        popd
      fi
  popd || exit 1
}

_build_qemu() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("${@:-}")

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1

    ls -l "${WINDRES:-''}"* || true
    MSYS2_ARG_CONV_EXCL="*" ninja -j"${CPU_COUNT}"
     #> "${SRC_DIR}"/_make-"${qemu_arch}".log 2>&1
    # make check > "${SRC_DIR}"/_check-"${qemu_arch}".log 2>&1
    ninja install
     #> "${SRC_DIR}"/_install-"${qemu_arch}".log 2>&1

  popd || exit 1
}
