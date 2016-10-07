#!/bin/bash

set -e
set -x

# Build dependencies
export FLATBUFFERS_HOME=$PREFIX

cd cpp

# Build googletest for running unit tests

./thirdparty/download_thirdparty.sh
./thirdparty/build_thirdparty.sh gtest

source thirdparty/versions.sh
export GTEST_HOME=`pwd`/thirdparty/$GTEST_BASEDIR

mkdir build-dir
cd build-dir

cmake \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DARROW_BUILD_BENCHMARKS=off \
    -DARROW_HDFS=on \
    ..

make -j4
ctest -VV -L unittest
make install
