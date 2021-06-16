#!/bin/sh

mkdir build && cd build

cmake ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      $SRC_DIR

make -j${CPU_COUNT}
make install
