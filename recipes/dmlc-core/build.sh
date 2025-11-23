#!/bin/bash

set -ex

mkdir -p build
cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DUSE_OPENMP=ON

make -j${CPU_COUNT}
make install
