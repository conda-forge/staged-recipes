#!/bin/sh
if [ -n "${RAPP_INSTALL_DIR:-}" ]; then
    export CONDA_BACKUP_RAPP_INSTALL_DIR="${RAPP_INSTALL_DIR}"
fi
export RAPP_INSTALL_DIR="${CONDA_PREFIX}/bin"
