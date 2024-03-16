#!/bin/bash

mkdir build
cd build

cmake ${CMAKE_ARGS} ..

make VERBOSE=1 -j${CPU_COUNT}
make install

# Duplicate folder. Not needed
rm -rf ${PREFIX}/hip
