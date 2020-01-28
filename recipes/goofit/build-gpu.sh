#!/usr/bin/env bash
set -evx

export MAKEFLAGS="-j${CPU_COUNT}"
export GOOFIT_DEVICE=CUDA
export GOOFIT_ARCH="3.0;5.0;6.0;7.0+PTX"

# export CFLAGS="${CFLAGS} -I/usr/include"
# export CXXFLAGS="${CXXFLAGS} -I/usr/include"

rm pyproject.toml || echo "Already removed pyproject file"
$PYTHON -m pip install --no-deps --ignore-installed -v .
