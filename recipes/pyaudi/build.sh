#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DAUDI_BUILD_AUDI=no \
    -DAUDI_BUILD_MAIN=no \
    -DAUDI_BUILD_TESTS=no \
    -DAUDI_BUILD_PYAUDI=yes \
    ..

make

ctest

make install