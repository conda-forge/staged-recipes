#!/bin/bash

cmake -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib     \
      -DDISABLE_ARCH_NATIVE=ON       \
      $SRC_DIR

make install
