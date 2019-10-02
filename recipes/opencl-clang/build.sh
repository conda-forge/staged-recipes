#!/bin/bash

mkdir build
cd build

export CXXFLAGS="$CXXFLAGS"' -DPRIu64=\"lu\"'
export LDFLAGS="$LDFLAGS -Wl,--exclude-libs,ALL"

cmake \
    -DLLVM_DIR=$PREFIX/lib/cmake/llvm \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DLLVMSPIRV_INCLUDED_IN_LLVM=no \
    -DSPIRV_TRANSLATOR_DIR=$PREFIX \
    -DCOMMON_CLANG_LIBRARY_NAME=opencl_clang \
    ..

make -j${CPU_COUNT} VERBOSE=1
make install

