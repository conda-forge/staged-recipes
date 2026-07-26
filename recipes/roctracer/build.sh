#!/bin/bash

set -xeuo pipefail

GPU_LIST="gfx900 gfx906 gfx908 gfx90a gfx940 gfx1030 gfx1100 gfx1101 gfx1102"

mkdir build
pushd build

cmake ${CMAKE_ARGS}\
    -DGPU_TARGETS="$GPU_LIST" \
     ..

make
make mytest

make install
