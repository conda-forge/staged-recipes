#!/bin/bash

mkdir build && cd build

cmake \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DTLX_BUILD_SHARED_LIBS=ON \
  ..
make -j$CPU_COUNT
make install
