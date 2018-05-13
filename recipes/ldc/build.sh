#!/bin/bash
set -eu -o pipefail

# Build older compiler
cd lts
mkdir build
cd build
cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$SRC_DIR/install \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      ..
ninja install
cd $SRC_DIR
rm -rf ldc

# Build latest version
mkdir build
cd build
cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DBUILD_SHARED_LIBS=ON \
      -DD_COMPILER=$SRC_DIR/install/bin/ldmd2 \
      ..
ninja install
ldc2 -version

