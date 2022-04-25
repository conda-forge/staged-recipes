#!/bin/bash

cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib     \
      -DCMAKE_CXX_FLAGS=-O2     \
      -DQL_BUILD_EXAMPLES=OFF   \
      -DQL_BUILD_BENCHMARK=OFF   \
      $SRC_DIR
make install
