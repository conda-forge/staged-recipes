#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DBUILD_SPICE=yes \
    -DBUILD_MAIN=no \
    -DBUILD_PYKEP=yes \
    -DBUILD_TESTS=yes \
    ..

make

ctest

make install