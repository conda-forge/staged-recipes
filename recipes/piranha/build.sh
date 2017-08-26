#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DPIRANHA_WITH_BZIP2=yes \
    -DPIRANHA_WITH_ZLIB=yes  \
    -DBUILD_TESTS=yes \
    ..

make

if [ "$(uname)" == "Darwin" ]
then
    ctest -E "gastineau|pearce2_unpacked|s11n_perf" -V;
else
    ctest -E "gastineau|pearce2_unpacked" -V;
fi

make install
