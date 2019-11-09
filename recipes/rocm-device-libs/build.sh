#!/bin/bash

mkdir build
cd build

export CC=$PREFIX/bin/clang
export CXX=$PREFIX/bin/clang++
export CONDA_BUILD_SYSROOT=$PREFIX/$HOST/sysroot

cmake \
  -DLLVM_DIR=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  ..

make VERBOSE=1 -j${CPU_COUNT}
make install
