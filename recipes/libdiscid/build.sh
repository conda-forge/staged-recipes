#!/bin/bash
set -e
set -x

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=$PREFIX \
 -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE \
 -DCMAKE_INSTALL_LIBDIR=lib

make -j $CPU_COUNT

make install