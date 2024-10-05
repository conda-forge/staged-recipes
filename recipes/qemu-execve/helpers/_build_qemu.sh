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
  )

  _build_qemu "${qemu_arch}" "${build_dir}" "${install_dir}" "${qemu_args[@]}"
}

build_osx_qemu() {
  local qemu_arch=${1:-aarch64}
  local build_dir=${2:-"${SRC_DIR}"/_conda-build}
  local install_dir=${3:-"${PREFIX}"}

  qemu_args=(
    # "--target-list=aarch64-softmmu"
  )

  _build_qemu "${qemu_arch}" "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"
}

build_win_qemu() {
  local qemu_arch=${1:-aarch64}
  local build_dir=${2:-"${SRC_DIR}"/_conda-build}
  local install_dir=${3:-"${PREFIX}"}

  qemu_args=(
    "--target-list=${qemu_arch}-softmmu"
  )

  _build_qemu "${qemu_arch}" "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"
}

_build_qemu() {
  local qemu_arch=$1
  local build_dir=$2
  local install_dir=$3
  shift 3
  local qemu_args=("${@:-}")

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1
    export PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"
    export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig"
    export PKG_CONFIG_LIBDIR="${BUILD_PREFIX}/lib/pkgconfig"

    ../qemu-source/configure --help

    export CFLAGS="${CFLAGS} -D__APPLE__"
    ../qemu-source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      --disable-bsd-user --disable-guest-agent --disable-strip --disable-werror --disable-gcrypt --disable-pie \
      --disable-debug-info --disable-debug-tcg --enable-docs --disable-tcg-interpreter --enable-attr \
      --disable-brlapi --disable-linux-aio --disable-bzip2 --disable-cap-ng --disable-curl --disable-fdt \
      --disable-glusterfs --disable-gnutls --disable-nettle --disable-gtk --disable-rdma --disable-libiscsi \
      --disable-vnc-jpeg --disable-kvm --disable-lzo --disable-curses --disable-libnfs --disable-numa \
      --disable-opengl --disable-rbd --disable-vnc-sasl --disable-sdl --disable-seccomp \
      --disable-smartcard --disable-snappy --disable-spice --disable-libusb --disable-usb-redir --disable-vde \
      --disable-vhost-net --disable-virglrenderer --disable-virtfs --disable-vnc --disable-vte --disable-xen \
      --disable-xen-pci-passthrough --disable-system --disable-tools
       # > "${SRC_DIR}"/_configure-"${qemu_arch}".log 2>&1

    make -j"${CPU_COUNT}" > "${SRC_DIR}"/_make-"${qemu_arch}".log 2>&1
    make check > "${SRC_DIR}"/_check-"${qemu_arch}".log 2>&1
    make install > "${SRC_DIR}"/_install-"${qemu_arch}".log 2>&1

  popd || exit 1
}
