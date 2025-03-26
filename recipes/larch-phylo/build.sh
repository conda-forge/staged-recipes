#!/bin/bash

rm -rf build
mkdir build
cd build

export CMAKE_NUM_THREADS=8
cmake $CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release -DUSE_USHER=ON ..
make -j${CPU_COUNT}
make install
