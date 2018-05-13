#!/bin/bash
set -eu -o pipefail

# bootstrap with 0.17 which is the last version that doesn't require a host D compiler.
git clone --recursive https://github.com/ldc-developers/ldc.git -b ltsmaster
cd ldc
mkdir build
cd build
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=$SRC_DIR/install -DCMAKE_PREFIX_PATH=$PREFIX ..
ninja install
cd $SRC_DIR
rm -rf ldc

# build
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

