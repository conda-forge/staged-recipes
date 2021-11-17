#!/bin/bash

mkdir build
cd build

export CMAKE_LIBRARY_PATH=$PREFIX/lib

cmake $CMAKE_ARGS \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_OSX_SYSROOT="${SDKROOT}" \
  ..

make -j$CPU_COUNT VERBOSE=1
make install
