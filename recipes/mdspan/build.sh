#!/bin/bash

set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} \
  -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DMDSPAN_ENABLE_TESTS=OFF \
  -DMDSPAN_ENABLE_EXAMPLES=OFF \
  -DMDSPAN_ENABLE_BENCHMARKS=OFF \
  ..

cmake --build . --target install
