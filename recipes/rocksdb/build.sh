#!/bin/bash
set -eu

### Create Makefiles
cmake -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_BUILD_TYPE=Release \
      -DPORTABLE=ON \
      -DWITH_JEMALLOC=ON \
      -DWITH_LZ4=ON \
      -DWITH_RTTI=ON \
      -DWITH_SNAPPY=ON \
      -DWITH_TESTS=OFF \
      -DWITH_ZLIB=ON \
      -S . \
      -B Build

### Build
cd Build
make -j $CPU_COUNT

### Install
make install

### Copy the tools to $PREFIX/bin
cp tools/{ldb,rocksdb_{dump,undump},sst_dump} $PREFIX/bin
