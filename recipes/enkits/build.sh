#!/usr/bin/env bash

set -ex # Abort on error.

rm -rf build
mkdir build
cd build


cmake -GNinja \
    ${CMAKE_ARGS} \
    -DENKITS_BUILD_SHARED=ON \
    -DENKITS_BUILD_C_INTERFACE=ON \
    -DENKITS_BUILD_EXAMPLES=OFF \
    -DENKITS_INSTALL=ON \
    -DENKITS_SANITIZE=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.16 \
    ${SRC_DIR}

cmake --build . -j "${CPU_COUNT}"
cmake --build . --target install