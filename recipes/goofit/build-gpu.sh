#!/usr/bin/env bash
set -evx

export MAKEFLAGS="-j${CPU_COUNT}"
export GOOFIT_DEVICE=CUDA

export CFLAGS="${CFLAGS} -I/usr/include"
export CXXFLAGS="${CXXFLAGS} -I/usr/include"

rm pyproject.toml || echo "Already removed pyproject file"
$PYTHON -m pip install --no-deps --ignore-installed -v .
