#!/bin/env/bash
set -e

mkdir -p $SRC_DIR/build-release

cmake \
  -S $SRC_DIR/src  \
  -B $SRC_DIR/build-release  \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX}

cmake --build $SRC_DIR/build-release --parallel ${CPU_COUNT}

cmake --install $SRC_DIR/build-release
