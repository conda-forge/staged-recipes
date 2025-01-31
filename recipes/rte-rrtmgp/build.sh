#!/bin/bash
# Stop on any error
set -e

BUILD_DIR=build
BUILD_TYPE=Debug

FFLAGS='-ffree-line-length-none -m64 -std=f2008 -march=native -fbounds-check -fmodule-private -fimplicit-none -finit-real=nan'

BUILD_TESTING=ON
RTE_ENABLE_SP=OFF
KERNEL_MODE=default
FAILURE_THRESHOLD='7.e-4'

# Ensure the directories exist
mkdir -p "${BUILD_DIR}"
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include

# Note: $CMAKE_ARGS is automatically provided by conda-forge. 
# It sets default paths and platform-independent CMake arguments.
cmake -S . -B ${BUILD_DIR} \
      ${CMAKE_ARGS} \
      -DCMAKE_Fortran_COMPILER=$FC \
      -DCMAKE_Fortran_FLAGS="$FFLAGS" \
      -DRTE_ENABLE_SP=$RTE_ENABLE_SP \
      -DKERNEL_MODE=$KERNEL_MODE \
      -DBUILD_TESTING=$BUILD_TESTING \
      -DFAILURE_THRESHOLD=$FAILURE_THRESHOLD \
      -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -G Ninja

# Compile
cmake --build ${BUILD_DIR} --parallel

# Install the necessery files into the package
cmake --install ${BUILD_DIR} --prefix "${PREFIX}"

# Run tests
ctest --output-on-failure --test-dir ${BUILD_DIR} -V

if [ "$RUN_VALIDATION_PLOTS" = "True" ]; then
    cmake --build build --target validation-plots
fi
