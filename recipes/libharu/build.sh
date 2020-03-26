#!/bin/bash

set -ex

mkdir -p build
cd build

cmake $SRC_DIR -G "Ninja" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_LIBRARY_PATH=$PREFIX/lib \
  -DCMAKE_INCLUDE_PATH=$PREFIX/include \
  -DLIBHPDF_STATIC:BOOL=OFF

ninja -v install
