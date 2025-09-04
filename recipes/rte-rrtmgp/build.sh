#!/bin/bash
# Stop on any error
set -e

BUILD_DIR=build

BUILD_TYPE=Debug
RRTMGP_DATA_VERSION=v1.8.2
FP_MODEL=DP
RTE_CBOOL=ON
ENABLE_TESTS=ON
RTE_KERNELS=default
FAILURE_THRESHOLD=7.e-4

FCFLAGS="-ffree-line-length-none -m64 -std=f2008 -march=native -fbounds-check -fmodule-private -fimplicit-none -finit-real=nan -fbacktrace"

# Ensure the directories exist
mkdir -p "${BUILD_DIR}"
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include

# Note: $CMAKE_ARGS is automatically provided by conda-forge. 
# It sets default paths and platform-independent CMake arguments.
cmake -S . -B "${BUILD_DIR}" \
      ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -DCMAKE_Fortran_COMPILER=${FC} \
      -DCMAKE_Fortran_FLAGS="${FCFLAGS}" \
      -DRRTMGP_DATA_VERSION=${RRTMGP_DATA_VERSION} \
      -DPRECISION=${FP_MODEL} \
      -DUSE_C_BOOL=${RTE_CBOOL} \
      -DKERNEL_MODE=${RTE_KERNELS} \
      -DENABLE_TESTS=${ENABLE_TESTS} \
      -DFAILURE_THRESHOLD=${FAILURE_THRESHOLD} \
      -G Ninja

# Compile
cmake --build "${BUILD_DIR}" --parallel

# Install the necessery files into the package
cmake --install "${BUILD_DIR}" --prefix "${PREFIX}"

# Run tests
ctest --output-on-failure --test-dir "${BUILD_DIR}" -V
