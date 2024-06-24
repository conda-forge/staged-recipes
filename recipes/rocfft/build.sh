#!/bin/bash

set -xeuo pipefail

GPU_LIST="gfx900;gfx906;gfx908;gfx90a;gfx940;gfx1030;gfx1100;gfx1101;gfx1102"

mkdir build
pushd build

export DEVICE_LIB_PATH=${DEVICE_LIB_PATH}/amdgcn/bitcode

cmake ${CMAKE_ARGS} \
    -DCMAKE_CXX_COMPILER=hipcc \
    -DCMAKE_MODULE_PATH:PATH=$PREFIX/lib/cmake/hip \
    -DHIP_CLANG_PATH:PATH=$PREFIX/bin \
    -DSQLITE_USE_SYSTEM_PACKAGE:BOOL=ON \
    -DGPU_TARGETS="$GPU_LIST" \
    ..

make -j${CPU_COUNT}

make install
