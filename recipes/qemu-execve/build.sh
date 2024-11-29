#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/_build_qemu.sh"

# --- Main ---

if [[ "${build_platform:-"win-64"}" == "win-64" ]] && [[ "${target_platform:-"win-64"}" == "win-64" ]]; then
  build_win_qemu \
    "${SRC_DIR}/_conda_build" \
    "${SRC_DIR}/_conda_install"

# Build aarch64 on linux and windows with gcc
elif [[ "${build_platform}" == "linux-64" ]] && [[ "${target_platform}" == "linux-64" ]]; then
  build_linux_qemu \
    "${SRC_DIR}/_conda_build" \
    "${SRC_DIR}/_conda_install"

elif [[ "${build_platform}" == "osx-64" ]] && [[ "${target_platform}" == "osx-64" ]]; then
  qemu_arch="aarch64"
  build_osx_qemu \
    ${qemu_arch} \
    "${SRC_DIR}/_conda_build" \
    "${SRC_DIR}/_conda_install"

  # Changer RPATH to $PREFIX for qemu-img and qemu-system-aarch64 (for zstd)
  install_name_tool -add_rpath "${PREFIX}/lib" "${SRC_DIR}/_conda_install"/bin/qemu-img || true
  install_name_tool -add_rpath "${PREFIX}/lib" "${SRC_DIR}/_conda_install"/bin/qemu-system-aarch64 || true
  install_name_tool -add_rpath "${SRC_DIR}/_conda_install"/lib "${SRC_DIR}/_conda_install"/bin/qemu-system-aarch64 || true

  # Create empty image
  "${SRC_DIR}/_conda_install"/bin/qemu-img create \
     -f qcow2 \
     -o compression_type=zlib \
     "${SRC_DIR}/_conda_install/share/qemu/alpine-conda-vm.qcow2" \
     10G

  # Initialize qemu image
  python "${RECIPE_DIR}/helpers/qemu-user-aarch64.py" \
    --qemu-system "${SRC_DIR}/_conda_install/bin/qemu-system-aarch64" \
    --cdrom "${SRC_DIR}/alpine-virt-${ALPINE_ISO_VERSION}-aarch64.iso" \
    --drive "${SRC_DIR}/_conda_install/share/qemu/alpine-conda-vm.qcow2" \
    --socket "./qmp-sock" \
    --setup

  # Test qemu image
  python "${RECIPE_DIR}/helpers/qemu-user-aarch64.py" \
    --qemu-system "${SRC_DIR}/_conda_install/bin/qemu-system-aarch64" \
    --drive "${SRC_DIR}/_conda_install/share/qemu/alpine-conda-vm.qcow2" \
    --socket "./qmp-sock" \
    --run "conda --version"
    # --cdrom "${SRC_DIR}/custom-alpine.iso" \

  # sleep 60
  # python "${RECIPE_DIR}/helpers/qmp-vm-build.py"

  # Safety kill qemu if we have not been able to shutdown cleanly
  # sleep 120
  # kill $(cat qemu_pid.txt) || true
fi






  # "${SRC_DIR}/_conda_install"/bin/qemu-system-aarch64 \
  #   -name "Alpine AArch64" \
  #   -M virt \
  #   -accel tcg,thread=single \
  #   -cpu cortex-a57 \
  #   -m 2048 \
  #   -nographic \
  #   -boot menu=on \
  #   -drive if=pflash,format=raw,file="${SRC_DIR}/_conda_install/share/qemu/edk2-aarch64-code.fd",readonly=on \
  #   -drive if=pflash,format=raw,file="${SRC_DIR}_conda-init-${qemu_arch}/edk2-aarch64-vars.fd" \
  #   -drive file="${SRC_DIR}/_conda_install/share/qemu/user-disk-image.qcow2",format=qcow2 \
  #   -drive file="${SRC_DIR}/custom-alpine.iso",format=raw,readonly=on \
  #   -qmp unix:./qmp-sock,server \
  #   -boot menu=on \
  #   & echo $! > qemu_pid.txt
  # sleep 300

