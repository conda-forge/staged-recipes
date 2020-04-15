#!/bin/bash
set -eu

### Create Makefiles
cmake -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_BUILD_TYPE=Release \
      -DFAIL_ON_WARNINGS=ON \
      -DPORTABLE=ON \
      -DUSE_RTTI=ON \
      -DWITH_GFLAGS=ON \
      -DWITH_JEMALLOC=ON \
      -DWITH_LZ4=${rocksdb_lz4} \
      -DWITH_SNAPPY=${rocksdb_snappy} \
      -DWITH_TESTS=OFF \
      -DWITH_TOOLS=${rocksdb_tools} \
      -DWITH_ZLIB=${rocksdb_zlib} \
      -S . \
      -B Build

### Build
cd Build
make -j $CPU_COUNT

### Install
make install

### Copy the tools to $PREFIX/bin
# TODO: Check rocksdb_tools first
#cp tools/{ldb,rocksdb_{dump,undump},sst_dump} $PREFIX/bin
