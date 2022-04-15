#!/bin/bash -euo

PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"
CONDA_MESO="${CONDA_PREFIX}/conda-meso/${PKG_UUID}"

UNLINK_SCRIPT="${CONDA_MESO}/pre-unlink-aux.sh"

if [ -f "${UNLINK_SCRIPT}" ]; then
  source "${UNLINK_SCRIPT}"
  rm "${UNLINK_SCRIPT}"
fi
