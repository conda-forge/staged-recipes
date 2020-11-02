#!/bin/bash

set -ex

export CXXFLAGS="${CXXFLAGS} -std=c++11"

mkdir build
cd build

cmake -G "Unix Makefiles" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_LIBRARY_PATH=$PREFIX/lib \
  -DCMAKE_INCLUDE_PATH=$PREFIX/include \
  -DENABLE_TESTS=OFF \
  ..

make -j $CPU_COUNT
make install
