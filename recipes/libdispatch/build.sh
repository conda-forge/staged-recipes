#!/bin/bash

set -ex

cmake ${CMAKE_ARGS} \
    -G Ninja \
    -B build \
    -D BUILD_SHARED_LIBS=YES \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_C_COMPILER=clang \
    -D CMAKE_CXX_COMPILER=clang++ \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D CMAKE_PREFIX_PATH=${PREFIX} \
    -D BUILD_TESTING=NO \
    -S ${SRC_DIR}

cmake --build build -j ${CPU_COUNT} --target install
