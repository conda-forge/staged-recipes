#!/bin/bash

mkdir build
cd build

export CMAKE_LIBRARY_PATH=$PREFIX/lib

cmake $CMAKE_ARGS \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DPython3_EXECUTABLE=$PREFIX/bin/python \
  ..

make -j$CPU_COUNT
make install
