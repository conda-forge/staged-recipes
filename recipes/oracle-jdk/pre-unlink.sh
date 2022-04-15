#!/bin/bash -euo

PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"
MESO_DIR="${CONDA_PREFIX}/conda-meso/${PKG_UUID}"

REVERT_SCRIPT="${MESO_DIR}/pre-unlink-aux.sh"

if [ -f "${REVERT_SCRIPT}" ]; then
  source "${REVERT_SCRIPT}"
  rm "${REVERT_SCRIPT}"
fi
