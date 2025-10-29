#!/bin/bash

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
    export PYTHONPATH="${PYTHONPATH//${CONDA_PREFIX}\/grass84\/etc\/python:/}"
    if [ -z "${PYTHONPATH}" ]; then
        unset PYTHONPATH
    fi
fi