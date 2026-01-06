#!/bin/bash

git submodule update --init --recursive

rm -rf build
mkdir build
cd build

export CMAKE_NUM_THREADS=${CPU_COUNT}
cmake $CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release ..
make -j${CPU_COUNT}
make install
