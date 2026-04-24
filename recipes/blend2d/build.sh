#!/bin/bash
set -euxo pipefail

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBLEND2D_STATIC=OFF \
    -DBLEND2D_TEST=OFF \
    -DBLEND2D_EXTERNAL_ASMJIT=ON \
    -DBLEND2D_NO_STDCXX=OFF

cmake --build build
cmake --install build
