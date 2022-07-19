#!/usr/bin/env bash
set -ex

cmake \
    ${CMAKE_ARGS} \
    -B _build -G Ninja \
    -DPYTHON_EXECUTABLE=$PYTHON \
    -DSCINE_MARCH="" \
    -DSKIP_LIBRARY_BUILD=ON \
    -DSCINE_BUILD_TESTS=OFF \
    -DSCINE_BUILD_PYTHON_BINDINGS=ON \
    -DSCINE_USE_INTEL_MKL=OFF \
    -DSCINE_USE_STATIC_LINALG=OFF \
    -DSCINE_USE_LAPACKE=OFF \
    -DSCINE_USE_BLAS=OFF

cmake --build _build
cmake --install _build
