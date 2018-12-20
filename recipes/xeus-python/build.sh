#!/bin/bash

cmake -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DDISABLE_ARCH_NATIVE=ON       \
      -DCMAKE_INSTALL_LIBDIR=lib    \
      $SRC_DIR

make install
