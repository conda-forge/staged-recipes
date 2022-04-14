#!/bin/bash -euo

PKG_UUID="${PKG_NAME}-${PKG_VERSION}_${PKG_BUILDNUM}"
REVERT_SCRIPT="${CONDA_PREFIX}/conda-activate-meta/${PKG_UUID}/deactivate-aux.sh"

source "${REVERT_SCRIPT}"