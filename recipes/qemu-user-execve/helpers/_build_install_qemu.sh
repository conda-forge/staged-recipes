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
    "--enable-user"
    "--disable-system"
  )

  _build_qemu "${qemu_arch}" "${build_dir}" "${install_dir}" "${qemu_args[@]}"
}

install_qemu_arch() {
  local qemu_arch=${1:-aarch64}

  mkdir -p "${PREFIX}"/bin
  install -m 0755 "${SRC_DIR}/_conda-install-${qemu_arch}/bin/qemu-${qemu_arch}" "${PREFIX}/bin/${PKG_NAME}"

  # Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
  # This will allow them to be run on environment activation.
  for SCRIPT in "activate" "deactivate"
  do
    mkdir -p "${PREFIX}/etc/conda/${SCRIPT}.d"
    install -m 0755 "${RECIPE_DIR}/scripts/${SCRIPT}-${qemu_arch}.sh" "${PREFIX}/etc/conda/${SCRIPT}.d/${PKG_NAME}-${SCRIPT}.sh"
  done
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

    ${SRC_DIR}/qemu-source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      --disable-docs \
      --disable-bsd-user --disable-guest-agent --disable-strip --disable-werror --disable-gcrypt --disable-pie \
      --disable-debug-info --disable-debug-tcg --disable-tcg-interpreter \
      --disable-brlapi --disable-linux-aio --disable-bzip2 --disable-cap-ng --disable-curl --disable-fdt \
      --disable-glusterfs --disable-gnutls --disable-nettle --disable-gtk --disable-rdma --disable-libiscsi \
      --disable-vnc-jpeg --disable-kvm --disable-lzo --disable-curses --disable-libnfs --disable-numa \
      --disable-opengl --disable-rbd --disable-vnc-sasl --disable-sdl --disable-seccomp \
      --disable-smartcard --disable-snappy --disable-spice --disable-libusb --disable-usb-redir --disable-vde \
      --disable-vhost-net --disable-virglrenderer --disable-virtfs --disable-vnc --disable-vte --disable-xen \
      --disable-xen-pci-passthrough --disable-tools > "${SRC_DIR}"/_configure-"${qemu_arch}".log 2>&1

    pushd ${SRC_DIR}/qemu-source/subprojects/libvhost-user/standard-headers
      ls -lrt linux
      rm -rf linux
      ln -s ../../../include/standard-headers/linux linux
    popd
    pushd ${SRC_DIR}/qemu-source/subprojects/libvduse/linux-headers
      ls -lrt linux
      rm -rf linux
      ln -s ../../../linux-headers/linux linux
    popd
    pushd ${SRC_DIR}/qemu-source/subprojects/libvduse/standard-headers
      ls -lrt linux
      rm -rf linux
      ln -s ../../../include/standard-headers/linux linux
    popd
    pushd ${SRC_DIR}/qemu-source/subprojects/libvduse/standard-headers
      ls -lrt linux
      rm -rf linux
      ln -s ../../../include/standard-headers/linux linux
    popd

    make -j"${CPU_COUNT}" > "${SRC_DIR}"/_make-"${qemu_arch}".log 2>&1
    make check > "${SRC_DIR}"/_check-"${qemu_arch}".log 2>&1
    make install > "${SRC_DIR}"/_install-"${qemu_arch}".log 2>&1

  popd || exit 1
}
