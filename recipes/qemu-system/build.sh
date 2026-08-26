#!/usr/bin/env bash

set -euxo pipefail
IFS=$'\n\t'

source "${RECIPE_DIR}/helpers/build_install_qemu.sh"

# --- Main ---

# Ensure PYTHON is set for QEMU's configure
if is_unix; then
  export PYTHON="${BUILD_PREFIX}"/bin/python
  export QEMU_INSTALL_PREFIX="${PREFIX}"
else
  export PYTHON="${BUILD_PREFIX}/python.exe"
  export QEMU_INSTALL_PREFIX="${PREFIX}"/Library
  # Do we still need this for ninja on rattler-build?
  # export MSYS2_ARG_CONV_EXCL="*"
fi

QEMU_CONFIGURE_ARGS=(
  "--disable-docs"
  "--disable-linux-user"
  "--enable-system"
  "--target-list=${CONDA_QEMU_TARGET_LIST}"
)

is_unix || QEMU_CONFIGURE_ARGS+=(
  "--enable-fdt=internal"
  "--bindir=${QEMU_INSTALL_PREFIX}/bin"
  "--datadir=${QEMU_INSTALL_PREFIX}/share/qemu"
)
# TODO: macos 12 for pvg in feedstock
# TODO: revisit -- retained pending a separate HVF/codesign trial
[[ "${target_platform}" == osx-* ]] && QEMU_CONFIGURE_ARGS+=("--disable-pvg" "--disable-hvf")

# Platform-specific build
build_install_qemu "${SRC_DIR}/_conda-build" "${QEMU_INSTALL_PREFIX}" "${QEMU_CONFIGURE_ARGS[@]}"
