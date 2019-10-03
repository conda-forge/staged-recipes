#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    ..

cmake --build . -- -j${CPU_COUNT}
CTEST_OUTPUT_ON_FAILURE=1 ctest
cmake --build . --target install
