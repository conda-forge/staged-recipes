#!/bin/bash

set -e
set -x

# Build dependencies
export BOOST_ROOT=$PREFIX
export ARROW_HOME=$PREFIX
export SNAPPY_HOME=$PREFIX
export THRIFT_HOME=$PREFIX
export ZLIB_HOME=$PREFIX

mkdir build-dir
cd build-dir

cmake \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DPARQUET_ARROW=on \
    -DPARQUET_BUILD_BENCHMARKS=off \
    -DPARQUET_BUILD_TESTS=off \
    ..

make -j${CPU_COUNT}
make install
