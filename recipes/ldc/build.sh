#!/bin/bash
set -eu -o pipefail

# bootstrap
git clone --recursive https://github.com/ldc-developers/ldc.git -b release-0.17.1

# build and install LDC
cd ldc
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$SRC_DIR/install ..
make && make install
cd ..

# build and install rdmd
curl -L -O https://raw.githubusercontent.com/D-Programming-Language/tools/2.064/rdmd.d
$SRC_DIR/install/bin/ldmd2 rdmd.d
cp rdmd $SRC_DIR/install/bin

cd $SRC_DIR
rm -rf ldc

# end bootstrap

# build
HOST_LDMD=$SRC_DIR/install/bin/ldmd2
mkdir build
cd build
cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DBUILD_SHARED_LIBS=ON \
      -DD_COMPILER=$HOST_LDMD \
      $BOOTSTRAP_CMAKE_FLAGS
      ..
ninja install
ldc2 -version

