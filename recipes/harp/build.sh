#!/bin/bash

mkdir build
cd build

cmake $CMAKE_ARGS --trace \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DCMAKE_OSX_SYSROOT=${SDKROOT} \
  -DHARP_BUILD_PYTHON=True \
  -DHARP_BUILD_R=True \
  -DCODA_INCLUDE_DIR="$PREFIX/include" \
  -DCODA_LIBRARY_DIR="$PREFIX/lib" \
  -DJPEG_INCLUDE_DIR="$PREFIX/include" \
  -DJPEG_LIBRARY_DIR="${PREFIX}/lib" \
  -DJPEG_LIBRARY="${PREFIX}/lib/libjpeg${SHLIB_EXT}" \
  -DZLIB_INCLUDE_DIR="$PREFIX/include" \
  -DZLIB_LIBRARY="${PREFIX}/lib/libz${SHLIB_EXT}" \
  -DZLIB_LIBRARY_DIR="${PREFIX}/lib" \
  ..

make -j$CPU_COUNT
make install
