#!/usr/bin/env bash
set -ex

cmake -S "${SRC_DIR}/c" -B build \
    -GNinja \
    ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"

cmake --build build -j "${CPU_COUNT}"
cmake --install build
