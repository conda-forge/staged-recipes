#!/bin/bash

set -exo pipefail

GPU_LIST="gfx900;gfx906;gfx908;gfx90a;gfx940;gfx1030;gfx1100;gfx1101;gfx1102"

mkdir build && cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DROCM_PATH=$PREFIX \
    -DONLY_INSTALL=ON \
    -DGPU_TARGETS="$GPU_LIST" \
    -DUSE_HIPCXX=OFF \
    ..

make VERBOSE=1 -j${CPU_COUNT}
make install
