#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DPIRANHA_WITH_BZIP2=yes \
    -DPIRANHA_WITH_ZLIB=yes  \
    -DPIRANHA_WITH_MSGPACK=yes \
    -DPIRANHA_INSTALL_HEADERS=no \
    -DBUILD_TESTS=no \
    -DBUILD_PYRANHA=yes \
    ..

make -j2
make install

