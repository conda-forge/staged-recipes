#!/usr/bin/env bash

set -euxo pipefail
IFS=$'\n\t'

if [[ ${BASH_VERSINFO[0]} -lt 5 || (${BASH_VERSINFO[0]} -eq 5 && ${BASH_VERSINFO[1]} -lt 2) ]]; then
  echo "re-exec with conda bash..."
  if [[ -x "${BUILD_PREFIX}/bin/bash" ]]; then
    exec "${BUILD_PREFIX}/bin/bash" "$0" "$@"
  else
    echo "ERROR: Could not find conda bash at ${BUILD_PREFIX}/bin/bash"
    exit 1
  fi
fi

source "${RECIPE_DIR}/helpers/build_install_qemu.sh"
source "${RECIPE_DIR}/helpers/feature_profiles.sh"

# --- Main ---

# Ensure PYTHON is set for QEMU's configure
if [[ "${target_platform}" == "linux-"* ]] || [[ "${target_platform}" == "osx-"* ]]; then
  export PYTHON="${BUILD_PREFIX}"/bin/python
  export QEMU_INSTALL_PREFIX="${PREFIX}"
else
  export PYTHON="${BUILD_PREFIX}/python.exe"
  export QEMU_INSTALL_PREFIX="${PREFIX}"/Library
fi

echo "=== QEMU Build Configuration ==="
echo "CONDA_QEMU_TARGET_LIST: ${CONDA_QEMU_TARGET_LIST:-<empty>}"
echo "================================"

# Build configure arguments using feature profiles
# Bash 3.2 compat: build_configure_args assigns to the global
# QEMU_CONFIGURE_ARGS array instead of taking a nameref out-parameter.
build_configure_args "${target_platform}"
qemu_args=("${QEMU_CONFIGURE_ARGS[@]}")

# Platform-specific build
if [[ ${target_platform} == linux-* ]] || [[ ${target_platform} == osx-* ]]; then
  build_install_qemu "${SRC_DIR}/_conda-build" "${QEMU_INSTALL_PREFIX}" "${qemu_args[@]}"
else
  qemu_args+=(
    "--bindir=${QEMU_INSTALL_PREFIX}/bin"
    "--datadir=${QEMU_INSTALL_PREFIX}/share/qemu"
  )
  build_install_qemu_non_unix "${SRC_DIR}/_conda-build" "${QEMU_INSTALL_PREFIX}" "${qemu_args[@]}"
fi
