#!/bin/sh

mkdir build

cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -BUILD_DEPS=OFF \
      -DUSE_SCIP=OFF \
      -S. \
      -B build

cmake --build build --target install -j${CPU_COUNT}
