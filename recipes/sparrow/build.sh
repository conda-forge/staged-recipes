#!/bin/bash

cmake ${CMAKE_ARGS} -DBUILD_TESTS=OFF \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      $SRC_DIR

make install
