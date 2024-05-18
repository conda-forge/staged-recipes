#!/bin/bash

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DLLVM_DIR=$PREFIX/lib/cmake/llvm \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=$PREFIX \
    -DBUILD_SHARED_LIBS=yes \
    ..

make -j${CPU_COUNT}
