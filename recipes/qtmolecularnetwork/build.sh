#!/bin/sh

mkdir build
cd build

cmake \
  ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
  -DBUILD_STATIC=OFF \
  -DQMN_VERSION=${PKG_VERSION} \
  ..
make install -j${CPU_COUNT}

# License is included with conda package data
rm -rf $PREFIX/license
