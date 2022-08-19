#!/bin/bash

mkdir -p build && cd build

cmake ${CMAKE_ARGS} \
      -D CMAKE_BUILD_TYPE=Release \
      -D BUILD_SHARED_LIBS=OFF \
      -D CMAKE_INSTALL_PREFIX=${PREFIX} \
      -D CMAKE_INSTALL_LIBDIR=lib \
      -D INSTALL_LOCAL=OFF \
      ${SRC_DIR}

make -j${CPU_COUNT} ${VERBOSE_CM}

make install -j${CPU_COUNT}
