#!/usr/bin/env bash
set -ex

# CPU-only companion to the PyPI wheels (KF_WITH_CUDA=OFF).
# Prefer conda-forge BLAS on Linux; macOS uses Accelerate via CMake.
if [[ "${target_platform}" == osx-* ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS} -DKF_WITH_CUDA=OFF"
else
  export CMAKE_ARGS="${CMAKE_ARGS} -DKF_WITH_CUDA=OFF -DKF_BLAS_VENDOR=OpenBLAS"
fi

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
