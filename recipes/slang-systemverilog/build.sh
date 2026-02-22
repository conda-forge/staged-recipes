#!/bin/bash
set -exuo pipefail

mkdir build && cd build

cmake ${CMAKE_ARGS} \
    -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DSLANG_INCLUDE_TOOLS=ON \
    -DSLANG_INCLUDE_TESTS=OFF \
    -DSLANG_INCLUDE_DOCS=OFF \
    -DSLANG_INCLUDE_PYLIB=OFF \
    -DSLANG_INCLUDE_INSTALL=ON \
    -DSLANG_USE_MIMALLOC=ON \
    -DBUILD_SHARED_LIBS=ON \
    ..

ninja -j${CPU_COUNT}
ninja install
