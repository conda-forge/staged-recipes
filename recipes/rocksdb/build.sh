#!/bin/bash
set -eu

### Create Makefiles
cmake -g Ninja \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_BUILD_TYPE=Release \
      -DFAIL_ON_WARNINGS=ON \
      -DUSE_RTTI=ON \
      -DWITH_GFLAGS=ON \
      -DWITH_JEMALLOC=ON \
      -DWITH_LZ4=OFF \
      -DWITH_SNAPPY=ON \
      -DWITH_TESTS=OFF \
      -DWITH_TOOLS=OFF \
      -DWITH_ZLIB=OFF \
      -S src \
      -B build

### Build
cmake  --build build --

### Install
cmake --build build -- install

### Checking requires a recompile with DEBUG enabled
# cmake --build build -- check

### Copy the tools to $PREFIX/bin
# TODO: I someone needs the tools, please open a PR/issue.
# cp build/tools/{ldb,rocksdb_{dump,undump},sst_dump} $PREFIX/bin
