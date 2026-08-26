#!/usr/bin/env bash

set -euxo pipefail
IFS=$'\n\t'

source "${RECIPE_DIR}/helpers/build_install_qemu.sh"

# --- Main ---

# Ensure PYTHON is set for QEMU's configure
if [[ "${target_platform}" == "linux-"* ]] || [[ "${target_platform}" == "osx-"* ]]; then
  export PYTHON="${BUILD_PREFIX}"/bin/python
  export QEMU_INSTALL_PREFIX="${PREFIX}"
else
  export PYTHON="${BUILD_PREFIX}/python.exe"
  export QEMU_INSTALL_PREFIX="${PREFIX}"/Library
fi

QEMU_CONFIGURE_ARGS=(
  "--disable-docs"
  "--disable-linux-user"
  "--enable-system"
  "--target-list=${CONDA_QEMU_TARGET_LIST}"
  "--bindir=${QEMU_INSTALL_PREFIX}/bin"
  "--datadir=${QEMU_INSTALL_PREFIX}/share/qemu"
)
[[ "${target_platform}" == win-* ]] && QEMU_CONFIGURE_ARGS+=("--enable-fdt=internal")
# TODO: macos 12 for pvg in feedstock
# TODO: revisit -- retained pending a separate HVF/codesign trial
[[ "${target_platform}" == osx-* ]] && QEMU_CONFIGURE_ARGS+=("--disable-pvg" "--disable-hvf")

# Platform-specific build
if [[ ${target_platform} == linux-* ]] || [[ ${target_platform} == osx-* ]]; then
  build_install_qemu "${SRC_DIR}/_conda-build" "${QEMU_INSTALL_PREFIX}" "${QEMU_CONFIGURE_ARGS[@]}"
else
  build_install_qemu_non_unix "${SRC_DIR}/_conda-build" "${QEMU_INSTALL_PREFIX}" "${QEMU_CONFIGURE_ARGS[@]}"
fi
