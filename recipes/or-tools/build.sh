#!/bin/sh

cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -BUILD_DEPS=OFF \
      -DUSE_SCIP=OFF \
      -S. \
      -Bbuild

cmake --build build --target install -j${CPU_COUNT}
