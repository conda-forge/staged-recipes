#!/bin/bash

set -euxo pipefail

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_LINK_LLVM_DYLIB=ON \
  -DLLVM_BUILD_TOOLS=ON \
  -DLLVM_BUILD_UTILS=ON \
  -GNinja \
  ../mlir

ninja mlir-tblgen
mkdir -p $PREFIX/bin
cp bin/mlir-tblgen $PREFIX/bin
