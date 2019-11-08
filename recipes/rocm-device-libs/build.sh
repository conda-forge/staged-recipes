#!/bin/bash

mkdir build
cd build

export CC=$PREFIX/bin/clang
export CXX=$PREFIX/bin/clang++

cmake \
  -DLLVM_DIR=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  ..

make VERBOSE=1 -j${CPU_COUNT}
ctest
make install
