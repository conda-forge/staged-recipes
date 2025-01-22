#!/bin/env/bash
set -e

# Needed so that sfpi can be invoked at build time to generate object files
# sfpi links libmpc.so at runtime
export LD_LIBRARY_PATH=$PREFIX/lib

cmake \
  $CMAKE_ARGS \
  -G Ninja \
  -S $SRC_DIR \
  -B $SRC_DIR/build-release \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_SKIP_INSTALL_RPATH=ON

cmake --build $SRC_DIR/build-release

cmake --install $SRC_DIR/build-release
