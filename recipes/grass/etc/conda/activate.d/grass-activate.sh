#!/usr/bin/env bash

# Detect GRASS version directory dynamically (e.g., grass84 for version 8.4.x)
# This allows the script to work with any GRASS version without hardcoding
GRASS_VERSION_DIR=$(ls -d "${CONDA_PREFIX}"/grass[0-9]* 2>/dev/null | head -n1 | xargs -r basename)

if [ -z "${GRASS_VERSION_DIR}" ]; then
    echo "Warning: GRASS installation directory not found in ${CONDA_PREFIX}" >&2
    return 1
fi

# Add GRASS binaries to PATH
export GRASS_BIN_PATH="${CONDA_PREFIX}/${GRASS_VERSION_DIR}/bin"
export PATH="${GRASS_BIN_PATH}:${PATH}"

# Save old PYTHONPATH
if [ -n "${PYTHONPATH}" ]; then
    export _OLD_GRASS_PYTHONPATH="${PYTHONPATH}"
fi

# Add GRASS Python modules to PYTHONPATH
export PYTHONPATH="${CONDA_PREFIX}/${GRASS_VERSION_DIR}/etc/python:${PYTHONPATH:-}"