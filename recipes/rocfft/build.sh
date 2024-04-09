#!/bin/bash

set -xeuo pipefail

# GPU_LIST="gfx900 gfx906 gfx908 gfx90a gfx940 gfx1030 gfx1100 gfx1101 gfx1102"

mkdir build
pushd build

#    -DGPU_TARGETS="$GPU_LIST" \

cmake ${CMAKE_ARGS}\
    -DCMAKE_MODULE_PATH=$PREFIX/lib/cmake/hip \
    -DHIP_CLANG_PATH=$PREFIX/bin \
     ..

make
make mytest

make install
