#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/_build_qemu.sh"

# --- Main ---

if [[ "${build_platform:-"win-64"}" == "win-64" ]] && [[ "${target_platform:-"win-64"}" == "win-64" ]]; then
  qemu_arch="aarch64"
  build_win_qemu \
    "${SRC_DIR}/qemu-source" \
    "${SRC_DIR}/_conda-install-${qemu_arch}"

# Build aarch64 on linux and windows with gcc
elif [[ "${build_platform}" == "linux-64" ]] && [[ "${target_platform}" == "linux-64" ]]; then
  qemu_arch="aarch64"
  build_linux_qemu \
    ${qemu_arch} \
    "${qemu_arch}-conda-linux-gnu-" \
    "${BUILD_PREFIX}/${qemu_arch}-conda-linux-gnu/sysroot" \
    "${SRC_DIR}/qemu-source" \
    "${SRC_DIR}/_conda-install-${qemu_arch}"

  qemu_arch="ppc64le"
  sysroot_arch="powerpc64le"
  build_linux_qemu \
    ${qemu_arch} \
    "${sysroot_arch}-conda-linux-gnu-" \
    "${BUILD_PREFIX}/${sysroot_arch}-conda-linux-gnu/sysroot" \
    "${SRC_DIR}/qemu-source" \
    "${SRC_DIR}/_conda-install-${qemu_arch}"

#   qemu_arch="riscv64"
#   sysroot_arch="riscv64"
#   build_qemu \
#     ${qemu_arch} \
#     "${sysroot_arch}-conda-linux-gnu-" \
#     "${BUILD_PREFIX}/${sysroot_arch}-conda-linux-gnu/sysroot" \
#     "${SRC_DIR}/_conda-build-${qemu_arch}" \
#     "${SRC_DIR}/_conda-install-${qemu_arch}"

elif [[ "${build_platform}" == "osx-64" ]] && [[ "${target_platform}" == "osx-64" ]]; then
  qemu_arch="aarch64"
  build_osx_qemu \
    ${qemu_arch} \
    "${SRC_DIR}/qemu-source" \
    "${SRC_DIR}/_conda-install-${qemu_arch}"

  # Changer RPATH to $PREFIX for qemu-img and qemu-system-aarch64 (for zstd)
  install_name_tool -add_rpath "${PREFIX}/lib" "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-img || true
  install_name_tool -add_rpath "${PREFIX}/lib" "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-system-aarch64 || true

  # Create image
  "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-img create \
     -f qcow2 \
     -o compression_type=zlib \
     "${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/user-disk-image.qcow2" 10G

  # Initialize qemu image
  mkdir -p "${SRC_DIR}_conda-init-${qemu_arch}"
  cp "${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/edk2-arm-vars.fd" "${SRC_DIR}_conda-init-${qemu_arch}/edk2-aarch64-vars.fd"

  python qemu_user_emulator.py \
    --qemu-system "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-system-aarch64 \
    --ro-edk2 "${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/edk2-aarch64-code.fd" \
    --rw-edk2 "${SRC_DIR}_conda-init-${qemu_arch}/edk2-aarch64-vars.fd" \
    --image "${SRC_DIR}/alpine-virt-${ALPINE_ISO_VERSION}-aarch64.iso" \
    --user-image "${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/user-disk-image.qcow2" \
    --install-miniconda \
    --runtime 120

  # "${SRC_DIR}/_conda-install-${qemu_arch}"/bin/qemu-system-aarch64 \
  #   -name "Alpine AArch64" \
  #   -M virt \
  #   -accel tcg,thread=single \
  #   -cpu cortex-a57 \
  #   -m 2048 \
  #   -nographic \
  #   -drive if=pflash,format=raw,file="${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/edk2-aarch64-code.fd",readonly=on \
  #   -drive if=pflash,format=raw,file="${SRC_DIR}_conda-init-${qemu_arch}/edk2-aarch64-vars.fd" \
  #   -drive file="${SRC_DIR}/_conda-install-${qemu_arch}/share/qemu/user-disk-image.qcow2",format=qcow2 \
  #   -drive file="${SRC_DIR}/alpine-virt-${ALPINE_ISO_VERSION}-aarch64.iso",format=raw,readonly=on \
  #   -qmp unix:./qmp-sock,server \
  #   & echo $! > qemu_pid.txt

  # sleep 60
  # python "${RECIPE_DIR}/helpers/qmp-vm-build.py"

  # Safety kill qemu if we have not been able to shutdown cleanly
  # sleep 120
  # kill $(cat qemu_pid.txt) || true
fi
