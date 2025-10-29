#!/bin/bash

# Add GRASS binaries to PATH
export GRASS_BIN_PATH="${CONDA_PREFIX}/grass84/bin"
export PATH="${GRASS_BIN_PATH}:${PATH}"

# Save old PYTHONPATH
if [ -n "${PYTHONPATH}" ]; then
    export _OLD_GRASS_PYTHONPATH="${PYTHONPATH}"
fi

# Add GRASS Python modules to PYTHONPATH
export PYTHONPATH="${CONDA_PREFIX}/grass84/etc/python:${PYTHONPATH:-}"