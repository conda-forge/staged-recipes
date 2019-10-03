#!/bin/bash

mkdir build
cd build

export CXXFLAGS="$CXXFLAGS"' -DPRIu64=\"lu\"'

cmake \
    -DLLVM_DIR=$PREFIX/lib/cmake/llvm \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DIGC_TARGET__TOOLS_CLANG_DIR=$PREFIX/lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCOMMON_CLANG_LIBRARY_NAME=opencl_clang \
    -DIGC_PREFERRED_LLVM_VERSION=9.0.0 \
    ..

make -j${CPU_COUNT}
make install

