#!/usr/bin/env bash

set -ex

# No CMake find modules for dependencies provided, so we need to add them manually.
cp -v $RECIPE_DIR/cmake/* cmake/

cmake \
    $CMAKE_ARGS \
    -B _build -G Ninja \
    -DBUILD_SHARED_LIBS=ON \
    -DSCINE_MARCH="" \
    -DSCINE_USE_INTEL_MKL=OFF \
    -DSCINE_USE_STATIC_LINALG=OFF \
    -DSCINE_USE_LAPACKE=OFF \
    -DSCINE_USE_BLAS=OFF

cmake --build _build
cmake --install _build
