#!/bin/bash

mkdir build
cd build

export LDFLAGS="$LDFLAGS -Wl,--exclude-libs,ALL"
export CC=clang
export CXX=clang++

cmake \
    -DLLVM_DIR=$PREFIX/lib/cmake/llvm \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DLLVMSPIRV_INCLUDED_IN_LLVM=no \
    -DSPIRV_TRANSLATOR_DIR=$PREFIX \
    -DCOMMON_CLANG_LIBRARY_NAME=opencl_clang \
    ..

make -j${CPU_COUNT}
make install

