#!/bin/bash -euo

PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"
REVERT_SCRIPT="${CONDA_PREFIX}/conda-link-meta/${PKG_UUID}/pre-unlink-aux.sh"

source "${REVERT_SCRIPT}"

