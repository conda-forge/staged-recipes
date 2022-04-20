#!/bin/bash -euo

PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"
CONDA_MESO="${CONDA_PREFIX}/conda-meso/${PKG_UUID}"

UNLINK_SCRIPT="${CONDA_MESO}/unlink-aux.sh"

if [ -f "${UNLINK_SCRIPT}" ]; then
  echo "evaluating ${UNLINK_SCRIPT}" >> "${CONDA_PREFIX}/.messages.txt"
  source "${UNLINK_SCRIPT}"
  rm "${UNLINK_SCRIPT}"
else
  echo "could not find ${UNLINK_SCRIPT}" >> "${CONDA_PREFIX}/.messages.txt"
fi
