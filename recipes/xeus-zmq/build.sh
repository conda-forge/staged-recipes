#!/bin/bash

cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib     \
      $SRC_DIR

make install
