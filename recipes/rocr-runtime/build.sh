#!/bin/bash


cd src
mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DEXTRA_CFLAGS="$CXXFLAGS" \
  ..

make VERBOSE=1 -j${CPU_COUNT}
make install

