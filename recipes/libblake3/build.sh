#!/usr/bin/env bash
set -ex

cmake -S "${SRC_DIR}/c" -B build \
    -GNinja \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DBLAKE3_BUILD_SHARED=ON \
    -DBLAKE3_BUILD_TESTING=OFF

cmake --build build -j "${CPU_COUNT}"
cmake --install build
