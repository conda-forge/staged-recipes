#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"

if [[ `uname` == 'Darwin' ]]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
fi

$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
