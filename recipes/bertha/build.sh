#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release \
    ..

cmake --build . -- -j${CPU_COUNT}
cmake --build . --target install
