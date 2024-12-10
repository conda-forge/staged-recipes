_build_install_qemu() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("${@:-}")

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1
    export PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"
    export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig"
    export PKG_CONFIG_LIBDIR="${BUILD_PREFIX}/lib/pkgconfig"

    ${SRC_DIR}/qemu-source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      --enable-strip \
      --enable-user \
      --enable-seccomp \
      --enable-debug-info \
      --disable-tcg-interpreter \
      --disable-debug-tcg \
      --disable-docs \
      --disable-system \
      --disable-bsd-user --disable-guest-agent --disable-werror --disable-gcrypt --disable-pie \
      --disable-brlapi --disable-linux-aio --disable-bzip2 --disable-cap-ng --disable-curl --disable-fdt \
      --disable-glusterfs --disable-gnutls --disable-nettle --disable-gtk --disable-rdma --disable-libiscsi \
      --disable-vnc-jpeg --disable-kvm --disable-lzo --disable-curses --disable-libnfs --disable-numa \
      --disable-opengl --disable-rbd --disable-vnc-sasl --disable-sdl  \
      --disable-smartcard --disable-snappy --disable-spice --disable-libusb --disable-usb-redir --disable-vde \
      --disable-vhost-net --disable-virglrenderer --disable-virtfs --disable-vnc --disable-vte --disable-xen \
      --disable-xen-pci-passthrough --disable-tools > "${SRC_DIR}"/_configure-"${qemu_arch}".log 2>&1

    pushd ${SRC_DIR}/qemu-source/subprojects/libvhost-user/standard-headers
      rm -rf linux
      ln -s ../../../include/standard-headers/linux linux
    popd
    pushd ${SRC_DIR}/qemu-source/subprojects/libvduse/linux-headers
      rm -rf linux
      ln -s ../../../linux-headers/linux linux
    popd
    pushd ${SRC_DIR}/qemu-source/subprojects/libvduse/standard-headers
      rm -rf linux
      ln -s ../../../include/standard-headers/linux linux
    popd
    pushd ${SRC_DIR}/qemu-source/subprojects/libvduse/standard-headers
      rm -rf linux
      ln -s ../../../include/standard-headers/linux linux
    popd

    make -j"${CPU_COUNT}" > "${SRC_DIR}"/_make-"${qemu_arch}".log 2>&1
    # make check > "${SRC_DIR}"/_check-"${qemu_arch}".log 2>&1
    make install > "${SRC_DIR}"/_install-"${qemu_arch}".log 2>&1

  popd || exit 1
}
