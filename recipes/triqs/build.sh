#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    ..

cmake --build . -- -j${CPU_COUNT}
cmake --build . --target install

ctest
