#!/usr/bin/env bash
set -ex

# CPU-only. AUTO BLAS works with conda-forge netlib or openblas libblas.
# OpenBLAS thread helpers are gated by KF_HAVE_OPENBLAS_THREADS in CMake.
export CMAKE_ARGS="${CMAKE_ARGS} -DKF_WITH_CUDA=OFF -DKF_BLAS_VENDOR=AUTO"

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
