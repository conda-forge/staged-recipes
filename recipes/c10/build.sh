#!/bin/bash
cd c10
mkdir build
cd build

# The CUDA binaries seem to be broken
cmake ${CMAKE_ARGS} \
    -DHAVE_SOVERSION=ON \
    -DBUILD_SHARED_LIBS=ON \
    ..

make -j${CPU_COUNT}
make install
