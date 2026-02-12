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
source "${RECIPE_DIR}/helpers/desktop_assets.sh"

# --- Main ---

# Ensure PYTHON is set for QEMU's configure
if [[ "${target_platform}" == "linux-"* ]] || [[ "${target_platform}" == "osx-"* ]]; then
  export PYTHON="${BUILD_PREFIX}"/bin/python
  export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH}"
  export QEMU_INSTALL_PREFIX="${PREFIX}"
else
  export QEMU_INSTALL_PREFIX="${PREFIX}"/Library
fi

# Build configure arguments using feature profiles
qemu_args=()
build_configure_args qemu_args "${CONDA_QEMU_TARGET:-}" "${CONDA_QEMU_TOOLS:-}" "${target_platform}"

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

# Install desktop assets for common package (no target, no tools)
if [[ -z "${CONDA_QEMU_TARGET:-}" ]] && [[ -z "${CONDA_QEMU_TOOLS:-}" ]]; then
  install_qemu_desktop_assets "${SRC_DIR}/qemu_source" "${QEMU_INSTALL_PREFIX}"
fi
