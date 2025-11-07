#!/bin/bash
set -e

chmod a+x $SRC_DIR/single/single.py

cmake $SRC_DIR \
  -B build \
  -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DSOL2_SINGLE=ON 

cmake --build build --parallel --target install