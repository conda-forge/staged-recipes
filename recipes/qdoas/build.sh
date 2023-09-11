#!/bin/bash
set -e
set -x

mkdir build
cd build

cmake $CMAKE_ARGS \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCONDA_INCLUDE_DIR="$PREFIX/include" \
  -DCMAKE_CXX_FLAGS="-Wno-deprecated-declarations" \
  ..

make -j$CPU_COUNT VERBOSE=1
make install VERBOSE=1
