build_linux_qemu() {
  local qemu_arch=${1:-aarch64}
  local cross_prefix=${2:-"$qemu_arch"-conda-linux-gnu-}
  local interpreter_prefix=${3:-"${BUILD_PREFIX}"/"${qemu_arch}"-conda-linux-gnu/sysroot/lib64}
  local build_dir=${4:-"${SRC_DIR}"/_conda-build}
  local install_dir=${5:-"${PREFIX}"}

  qemu_args=(
    "--interp-prefix=${interpreter_prefix}"
    "--target-list=${qemu_arch}-linux-user"
    "--cross-prefix-${qemu_arch}=${cross_prefix}"
    "--enable-linux-user"
    "--enable-attr"
    "--disable-system"
    "--disable-fdt"
    "--disable-guest-agent"
    "--disable-tools"
    "--disable-virtfs"
  )

  export PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"
  export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig"
  export PKG_CONFIG_LIBDIR="${BUILD_PREFIX}/lib/pkgconfig"

  _configure_qemu "${qemu_arch}" "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"
  _build_qemu "${qemu_arch}" "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"
}

build_osx_qemu() {
  local qemu_arch=${1:-aarch64}
  local build_dir=${2:-"${SRC_DIR}"/_conda-build}
  local install_dir=${3:-"${PREFIX}"}

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
  )
    #"--enable-guest-agent"  # Not supported
    #"--extra-cflags=-maxv2"  # Makes compilation fail

  export PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"
  export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig"
  export PKG_CONFIG_LIBDIR="${BUILD_PREFIX}/lib/pkgconfig"

  _configure_qemu "${qemu_arch}" "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"
  _build_qemu "${qemu_arch}" "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"
}

build_win_qemu() {
  local build_dir=${1:-"${SRC_DIR}"/_conda-build}
  local install_dir=${2:-"${PREFIX}"}

  qemu_args=(
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

  _configure_qemu "${qemu_arch}" "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"

  WINDRES=$(echo "${WINDRES}" | sed 's|^\([a-zA-Z]\):|/\L\1|g')

  pushd "${build_dir}" || exit 1
    sed -i 's|\([a-zA-Z]\)\$*:[^ ]*windres|'"${WINDRES}"'|g' build.ninja config.status config-meson.cross meson-info/intro-targets.json
    touch -a -m ../meson.build build.ninja config.status config-meson.cross meson-info/intro-targets.json
    powershell -Command "Get-ChildItem -Recurse -File | Select-String -Pattern 'WINDRES' -CaseSensitive:\$false" || true
  popd || exit 1

  PYTHON_WIN="${build_dir}/pyvenv/Scripts/python.exe"
  PYTHON_WIN=$(echo "${PYTHON_WIN}" | sed 's|^\([a-zA-Z]\):|/\L\1|g')
  export PYTHON_WIN

  _build_qemu "${qemu_arch}" "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"
}

_configure_qemu() {
  local qemu_arch=$1
  local build_dir=$2
  local install_dir=$3
  shift 3
  local qemu_args=("${@:-}")

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1
    "${SRC_DIR}"/qemu_source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      --disable-docs \
      --disable-bsd-user --disable-strip --disable-werror --disable-gcrypt --disable-pie \
      --disable-debug-info --disable-debug-tcg --disable-tcg-interpreter \
      --disable-brlapi --disable-linux-aio --disable-bzip2 --disable-cap-ng --disable-curl \
      --disable-glusterfs --disable-gnutls --disable-nettle --disable-gtk --disable-rdma --disable-libiscsi \
      --disable-vnc-jpeg --disable-kvm --disable-lzo --disable-curses --disable-libnfs --disable-numa \
      --disable-opengl --disable-rbd --disable-vnc-sasl --disable-sdl --disable-seccomp \
      --disable-smartcard --disable-snappy --disable-spice --disable-libusb --disable-usb-redir --disable-vde \
      --disable-vhost-net --disable-virglrenderer --disable-vnc --disable-vte --disable-xen \
      --disable-xen-pci-passthrough
       #> "${SRC_DIR}"/_configure-"${qemu_arch}".log 2>&1
  popd || exit 1
}

_build_qemu() {
  local qemu_arch=$1
  local build_dir=$2
  local install_dir=$3
  shift 3
  local qemu_args=("${@:-}")

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1
    ninja -j"${CPU_COUNT}" -d explain
     #> "${SRC_DIR}"/_make-"${qemu_arch}".log 2>&1
    # make check > "${SRC_DIR}"/_check-"${qemu_arch}".log 2>&1
    ninja install
     #> "${SRC_DIR}"/_install-"${qemu_arch}".log 2>&1

  popd || exit 1
}
