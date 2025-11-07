#!/bin/bash
set -e

cmake $SRC_DIR \
  -B build \
  -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build --parallel --target install