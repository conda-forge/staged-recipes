#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/build_install_qemu.sh"

# --- Main ---

# Ensure PYTHON is set for QEMU's configure
if [[ "${target_platform}" == "linux-"* ]] || [[ "${target_platform}" == "osx-"* ]]; then
  export PYTHON="${BUILD_PREFIX}"/bin/python
  export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH}"
fi

qemu_args=(
  "--disable-linux-user"
  "--disable-docs"
)

# Add target-list only if specified (arch builds)
# Empty CONDA_QEMU_TARGET means build tools only (common package)
if [[ -n "${CONDA_QEMU_TARGET:-}" ]]; then
  qemu_args+=("--enable-system" "--target-list=${CONDA_QEMU_TARGET}-softmmu")
else
  # Common package: build tools only, no system emulators
  qemu_args+=("--disable-system")
fi

if [[ ${target_platform} == linux-* ]] || [[ ${target_platform} == osx-* ]]; then
  build_install_qemu "${SRC_DIR}/_conda-build" "${PREFIX}" "${qemu_args[@]}"
else
  qemu_args+=(
    "--datadir=share/qemu"
    "--disable-install-blobs"
  )
    #"--disable-attr"
  build_install_qemu_non_unix "${SRC_DIR}/_conda-build" "${_PREFIX_}/Library" "${qemu_args[@]}"
fi
