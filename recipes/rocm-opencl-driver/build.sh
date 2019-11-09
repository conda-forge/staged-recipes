#!/bin/bash

mkdir build
cd build

cmake \
  -DLLVM_DIR=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  ..

make VERBOSE=1 -j${CPU_COUNT}
ctest -E roc-cl-unittest
make install

mkdir -p ${PREFIX}/include
cp ../src/driver/AmdCompiler.h ${PREFIX}/include
