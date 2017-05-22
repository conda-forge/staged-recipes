#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DMPPP_WITH_MPFR=yes \
    -DMPPP_BUILD_TESTS=yes \
    ..

make

ctest

make install
