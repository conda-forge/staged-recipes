#!/bin/bash

mkdir build && cd  build

cmake ${CMAKE_ARGS} -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_INSTALL_LIBDIR=$PREFIX/lib \
      -D CMAKE_BUILD_TYPE=Release \
      -D BUILD_PYTHON=ON\
      -D CMAKE_ASM_NASM_COMPILER=yasm \
      $SRC_DIR

make -j$CPU_COUNT
make install -j$CPU_COUNT
