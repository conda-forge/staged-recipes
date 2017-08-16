#!/bin/bash

set -e
set -x

export PARQUET_BUILD_TOOLCHAIN=$PREFIX

# Use PARQUET_ARROW_VERSION if it's already defined by the caller
export PARQUET_ARROW_VERSION=${PARQUET_ARROW_VERSION:=3a84653a3aa00f36f6312a11e58d1daf41dedcee}

mkdir build-dir
cd build-dir

cmake \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
    -DPARQUET_BOOST_USE_SHARED=off \
    -DPARQUET_BUILD_BENCHMARKS=off \
    -DPARQUET_BUILD_EXECUTABLES=off \
    -DPARQUET_BUILD_TESTS=off \
    ..

make -j${CPU_COUNT}
make install
