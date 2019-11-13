#!/bin/bash

mkdir build
cd build

cmake \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE=Release \
  -DFMT_TEST=OFF \
  -DFMT_DOC=OFF \
  -DFMT_INSTALL=ON \
  ..

make -j${CPU_COUNT} install
