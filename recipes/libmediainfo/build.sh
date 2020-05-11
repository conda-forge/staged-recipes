#!/bin/bash
set -eu

### Create Makefiles
cmake -g Ninja \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_ZENLIB=OFF \
      -DBUILD_ZLIB=OFF \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_BUILD_TYPE=Release \
      -DINCLUDE_INSTALL_DIR=$PREFIX/include \
      -S Project/CMake \
      -B build

### Build
cmake  --build build -- -j${CPU_COUNT}

### Install
cmake --build build -- install

### Test / Check ?
### There is no make check/test
