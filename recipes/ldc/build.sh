#!/bin/bash
set -eu -o pipefail

# bootstrap with 0.17.x which is the last version that doesn't require a host D compiler.
# See https://wiki.dlang.org/Building_LDC_from_source
# Use ltsmaster branch until https://github.com/ldc-developers/ldc/issues/2663 is fixed and 0.17.6 is released
git clone --recursive https://github.com/ldc-developers/ldc.git -b ltsmaster
cd ldc
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

