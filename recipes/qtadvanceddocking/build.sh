#!/bin/sh

mkdir build
cd build

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
  -DBUILD_STATIC=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DADS_VERSION=${PKG_VERSION} \
  ..
make install -j${CPU_COUNT}

