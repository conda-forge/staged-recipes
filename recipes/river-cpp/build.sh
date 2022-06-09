#!/bin/bash

set -x -e
set -o pipefail

cd cpp
mkdir -p build/release
cd build/release
cmake -G "Unix Makefiles" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DRIVER_BUILD_INGESTER=ON \
  -DRIVER_BUILD_TESTS=OFF \
  -DRIVER_INSTALL=ON \
  ${CMAKE_ARGS} \
  ../..
make
make install

