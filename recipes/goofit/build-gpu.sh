#!/usr/bin/env bash
set -evx

export MAKEFLAGS="-j${CPU_COUNT}"
export GOOFIT_DEVICE=CUDA
export GOOFIT_ARCH="3.0;5.0;6.0;7.0+PTX"

rm pyproject.toml || echo "Already removed pyproject file"
$PYTHON -m pip install --no-deps --ignore-installed -v .
