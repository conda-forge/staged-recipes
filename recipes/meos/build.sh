#!/bin/bash

mkdir -p build && cd build

cmake ${CMAKE_ARGS} \
      -D CMAKE_BUILD_TYPE=Release \
      -D MEOS=on \
      -D GSL_INCLUDE_DIR=$PREFIX/lib \
      -D GSL_LIBRARY=$PREFIX/lib \
      -D GSL_CBLAS_LIBRARY=$PREFIX/lib \
      -D PROJ_INCLUDE_DIRS=$PREFIX/include \
      -D PROJ_LIBRARIES=$PREFIX/lib \
      ${SRC_DIR}

make -j

make install