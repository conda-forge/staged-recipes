#!/bin/bash

cmake -DCMAKE_BUILD_TYPE=Release      \
      -DCMAKE_INSTALL_PREFIX=$PREFIX  \
      -DCMAKE_PREFIX_PATH=$PREFIX     \
      -DCMAKE_INSTALL_LIBDIR=lib      \
      -DXEUS_WREN_DISABLE_ARCH_NATIVE=ON   \
      $SRC_DIR

make install