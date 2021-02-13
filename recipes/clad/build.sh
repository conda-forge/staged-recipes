#!/bin/bash

cmake -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      $SRC_DIR/source

make -j${CPU_COUNT}
make install
