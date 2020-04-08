#!/bin/bash
set -e
set -x
cd blend2d
mkdir build-$SUBDIR-$c_compiler
cd build-$SUBDIR-$c_compiler

cmake .. -G "Ninja" \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=$PREFIX \
 -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE \
 -DCMAKE_INSTALL_LIBDIR=lib

cmake --build . --target install




