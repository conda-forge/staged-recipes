#!/bin/bash

set -e
set -x

# Build dependencies
export FLATBUFFERS_HOME=$PREFIX

cd cpp
mkdir build-dir
cd build-dir

cmake \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DARROW_BUILD_BENCHMARKS=off \
    -DARROW_BUILD_TESTS=off \
    -DARROW_HDFS=on \
    ..

make -j${CPU_COUNT}
make install
