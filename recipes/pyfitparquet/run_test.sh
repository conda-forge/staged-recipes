#!/usr/bin/env bash

set -e

if [ ! -z ${CONDA_BUILD_STATE+x} ]; then
    echo "For testing, setting CONDA_PREFIX to (install) PREFIX"
    export CONDA_PREFIX="${PREFIX}"
fi

python test/test_pyfitparquet.py
exit 0
