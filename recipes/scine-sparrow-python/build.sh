#!/usr/bin/env bash
set -ex

cmake \
    ${CMAKE_ARGS} \
    -B _build -G Ninja \
    -DPYTHON_EXECUTABLE=$PYTHON \
    -DSCINE_MARCH="" \
    -DSCINE_SKIP_LIBRARY=ON \
    -DSCINE_BUILD_TESTS=OFF \
    -DSCINE_BUILD_PYTHON_BINDINGS=ON
cmake --build _build
cmake --install _build
