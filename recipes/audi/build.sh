#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DAUDI_BUILD_AUDI=yes \
    -DAUDI_BUILD_MAIN=no \
    -DAUDI_BUILD_TESTS=yes \
    -DAUDI_BUILD_PYAUDI=no \
    ..

make

ctest

make install