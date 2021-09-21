#!/usr/bin/env bash
set -e -x

mkdir build
cd build

cmake \
    -DENABLE_FORMAT=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON \
    -DWITH_MYSQLCOMPAT=1 \
    -DINSTALL_LIBDIR=lib \
    ..

make -k -j${CPU_COUNT} || true

make install