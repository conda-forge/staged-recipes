#!/bin/bash

mkdir build
cd build

cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DIMATH_LIB_SUFFIX="" \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ..

make -j${CPU_COUNT}
make install