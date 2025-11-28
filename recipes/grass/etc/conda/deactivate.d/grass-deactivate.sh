#!/usr/bin/env bash

# Detect GRASS version directory dynamically (e.g., grass84 for version 8.4.x)
GRASS_VERSION_DIR=$(ls -d "${CONDA_PREFIX}"/grass[0-9]* 2>/dev/null | head -n1 | xargs -r basename)

if [ -z "${GRASS_VERSION_DIR}" ]; then
    # If detection fails, skip cleanup (maybe already uninstalled)
    GRASS_VERSION_DIR="grass"
fi

# Remove GRASS binaries from PATH
if [ -n "${GRASS_BIN_PATH}" ]; then
    export PATH="${PATH//${GRASS_BIN_PATH}:/}"
    unset GRASS_BIN_PATH
fi

# Restore old PYTHONPATH
if [ -n "${_OLD_GRASS_PYTHONPATH}" ]; then
    export PYTHONPATH="${_OLD_GRASS_PYTHONPATH}"
    unset _OLD_GRASS_PYTHONPATH
else
    # Remove GRASS Python path
    export PYTHONPATH="${PYTHONPATH//${CONDA_PREFIX}\/${GRASS_VERSION_DIR}\/etc\/python:/}"
    if [ -z "${PYTHONPATH}" ]; then
        unset PYTHONPATH
    fi
fi