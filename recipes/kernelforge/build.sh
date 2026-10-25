#!/usr/bin/env bash
set -ex

# CPU-only. Pin OpenBLAS via recipe deps so openblas_get_num_threads resolves.
export CMAKE_ARGS="${CMAKE_ARGS} -DKF_WITH_CUDA=OFF -DKF_BLAS_VENDOR=OpenBLAS"

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
