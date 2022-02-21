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

ninja mlir-linalg-ods-gen mlir-linalg-ods-yaml-gen
mkdir -p $PREFIX/bin
cp bin/mlir-linalg-ods-gen bin/mlir-linalg-ods-yaml-gen $PREFIX/bin
