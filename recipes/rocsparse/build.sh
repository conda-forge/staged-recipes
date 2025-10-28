#!/bin/bash

set -exo pipefail

mkdir build && cd build

export HIP_DEVICE_LIB_PATH=$PREFIX/lib/amdgcn/bitcode/

cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_MODULE_PATH=${PREFIX}/lib/cmake/hip \
    -DCMAKE_SHARED_LIBS=ON \
    ..

make VERBOSE=1 -j${CPU_COUNT}
make install