#!/bin/bash

set -e
set -x

# Build dependencies
export ARROW_BUILD_TOOLCHAIN=$PREFIX

cd cpp
mkdir build-dir
cd build-dir

cmake \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
    -DARROW_BOOST_USE_SHARED=off \
    -DARROW_BUILD_BENCHMARKS=off \
    -DARROW_BUILD_UTILITIES=off \
    -DARROW_BUILD_TESTS=off \
    -DARROW_JEMALLOC=off \
    -DARROW_PYTHON=on \
    ..

make -j${CPU_COUNT}
make install
