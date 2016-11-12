#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DPIRANHA_WITH_BZIP2=yes \
    -DPIRANHA_WITH_ZLIB=yes  \
    -DBUILD_TESTS=yes \
    ..

make
ctest -E "gastineau"
make install
