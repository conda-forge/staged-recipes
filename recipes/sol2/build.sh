#!/bin/bash
set -e

cmake $SRC_DIR \
  -B build \
  -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DSOL2_SINGLE=ON 

cmake --build build --parallel --target install