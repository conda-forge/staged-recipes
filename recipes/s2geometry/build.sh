#!/bin/bash
set -eu

mkdir build
cd build

### Create Makefiles
cmake \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_EXAMPLES=OFF \
      -UGTEST_ROOT \
      $SRC_DIR

### Build
cmake --build . -- -j${CPU_COUNT}

### Install
cmake --build . -- install
