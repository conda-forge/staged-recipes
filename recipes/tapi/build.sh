#!/bin/bash

mkdir build
cd build

cmake \
    -G Ninja \
    -C $SRC_DIR/tapi/cmake/caches/apple-tapi.cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_ASM_COMPILER=clang \
    $SRC_DIR/llvm

ninja install-distribution
