#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/_build_qemu.sh"

# --- Main ---

# Build aarch64 on linux and windows with gcc
if [[ "${build_platform}" == "linux-64" ]] && [[ "${target_platform}" == "linux-64" ]]; then
  qemu_arch="aarch64"
  build_linux_qemu \
    ${qemu_arch} \
    "${qemu_arch}-conda-linux-gnu-" \
    "${BUILD_PREFIX}/${qemu_arch}-conda-linux-gnu/sysroot" \
    "${SRC_DIR}/_conda-build-${qemu_arch}" \
    "${SRC_DIR}/_conda-install-${qemu_arch}"

  qemu_arch="ppc64le"
  sysroot_arch="powerpc64le"
  build_linux_qemu \
    ${qemu_arch} \
    "${sysroot_arch}-conda-linux-gnu-" \
    "${BUILD_PREFIX}/${sysroot_arch}-conda-linux-gnu/sysroot" \
    "${SRC_DIR}/_conda-build-${qemu_arch}" \
    "${SRC_DIR}/_conda-install-${qemu_arch}"

#   qemu_arch="riscv64"
#   sysroot_arch="riscv64"
#   build_qemu \
#     ${qemu_arch} \
#     "${sysroot_arch}-conda-linux-gnu-" \
#     "${BUILD_PREFIX}/${sysroot_arch}-conda-linux-gnu/sysroot" \
#     "${SRC_DIR}/_conda-build-${qemu_arch}" \
#     "${SRC_DIR}/_conda-install-${qemu_arch}"
fi

if [[ "${build_platform}" == "osx-64" ]] && [[ "${target_platform}" == "osx-64" ]]; then
  qemu_arch="aarch64"
  build_osx_qemu \
    ${qemu_arch} \
    "${SRC_DIR}/_conda-build-${qemu_arch}" \
    "${SRC_DIR}/_conda-install-${qemu_arch}"

  # Changer RPATH to $PREFIX for qemu-img and qemu-system-aarch64 (for zstd)
  install_name_tool -add_rpath "${PREFIX}/lib" "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-img
  install_name_tool -add_rpath "${PREFIX}/lib" "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-system-aarch64

  # Create image
  "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-img create \
     -f qcow2 \
     -o compression_type=zlib \
     "${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/user-disk-image.qcow2" 10G

  # Initialize qemu image
  mkdir -p "${SRC_DIR}_conda-init-${qemu_arch}"
  cp "${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/edk2-arm-vars.fd" "${SRC_DIR}_conda-init-${qemu_arch}/edk2-aarch64-vars.fd"

  "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-system-aarch64 \
    -name "Alpine AArch64" \
    -M virt \
    -accel tcg,thread=single \
    -cpu cortex-a57 \
    -m 2048 \
    -nographic \
    -drive if=pflash,format=raw,file="${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/edk2-aarch64-code.fd",readonly=on \
    -drive if=pflash,format=raw,file="${SRC_DIR}_conda-init-${qemu_arch}/edk2-aarch64-vars.fd" \
    -drive file="${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/user-disk-image.qcow2",format=qcow2 \
    -drive file="${SRC_DIR}/alpine-virt-${ALPINE_ISO_VERSION}-aarch64.iso",format=raw,readonly=on \
    -boot menu=on \
    -qmp unix:./qmp-sock,server \
    --monitor stdio \
    & echo $! > qemu_pid.txt

  python "${RECIPE_DIR}/helpers/qmp-connect.py"

  sleep 15
  kill $(cat qemu_pid.txt)
fi
