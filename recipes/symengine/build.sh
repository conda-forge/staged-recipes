#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"
export MACOSX_DEPLOYMENT_TARGET=10.9

mkdir build
cd build

cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_BENCHMARKS=no \
    -DINTEGER_CLASS=gmp \
    -DWITH_SYMENGINE_THREAD_SAFE=yes \
    -DWITH_MPC=yes \
    -DBUILD_SHARED_LIBS=yes \
    ..

make
make install

ctest
