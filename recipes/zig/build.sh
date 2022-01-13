#!/usr/bin/env bash

set -ex

mkdir -p build
cd build

cmake .. ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=${CC} \
  -DCMAKE_CXX_COMPILER=${CXX} \
  -DZIG_PREFER_CLANG_CPP_DYLIB=yes

cmake --build .
cmake --install . -v
