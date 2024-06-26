#!/bin/bash

set -xeuo pipefail

cd openmm-hip

mkdir build
pushd build

export DEVICE_LIB_PATH=${DEVICE_LIB_PATH}/amdgcn/bitcode

cmake ${CMAKE_ARGS} \
    -DCMAKE_CXX_COMPILER=hipcc \
    -DCMAKE_MODULE_PATH:PATH=$PREFIX/lib/cmake/hip \
    -DOPENMM_SOURCE_DIR:PATH=${SRC_DIR}/openmm \
    ..

make -j${CPU_COUNT}

make install
