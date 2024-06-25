#!/bin/bash

set -xeuo pipefail

mkdir build
pushd build

export DEVICE_LIB_PATH=${DEVICE_LIB_PATH}/amdgcn/bitcode

cmake ${CMAKE_ARGS} \
    -DCMAKE_CXX_COMPILER=hipcc \
    -DCMAKE_MODULE_PATH:PATH=$PREFIX/lib/cmake/hip \
    -DHIP_CLANG_PATH:PATH=$PREFIX/bin \
    ..

make -j${CPU_COUNT}

make install