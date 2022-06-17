#!/bin/bash

mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DTYPE_SAFE_BUILD_TEST_EXAMPLE=OFF \
  ..

make install
