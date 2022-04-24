#!/bin/bash

cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib     \
      -DCMAKE_CXX_FLAGS=-O2     \
      $SRC_DIR
make install
