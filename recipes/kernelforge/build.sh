#!/usr/bin/env bash
set -ex

# CPU-only (matches PyPI wheels). Do not force OpenBLAS: conda-forge's
# libblas variant is often netlib, and BLA_VENDOR=OpenBLAS then fails FindBLAS.
export CMAKE_ARGS="${CMAKE_ARGS} -DKF_WITH_CUDA=OFF -DKF_BLAS_VENDOR=AUTO"

if [[ "${target_platform}" == osx-* ]]; then
  # Point CMake at conda-forge llvm-openmp (AppleClang needs explicit hints).
  export CMAKE_ARGS="${CMAKE_ARGS} \
    -DOpenMP_C_FLAGS=-fopenmp=libomp \
    -DOpenMP_CXX_FLAGS=-fopenmp=libomp \
    -DOpenMP_C_LIB_NAMES=omp \
    -DOpenMP_CXX_LIB_NAMES=omp \
    -DOpenMP_omp_LIBRARY=${PREFIX}/lib/libomp.dylib \
    -DOpenMP_ROOT=${PREFIX}"
fi

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
