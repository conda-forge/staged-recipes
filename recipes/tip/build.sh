#!/bin/bash

mkdir build
cd build 

cmake ${CMAKE_ARGS} .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib

# make -j${CPU_COUNT}
make -j8
make install 