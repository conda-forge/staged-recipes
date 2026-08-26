#!/bin/bash

set -ex

mkdir -p build && cd build

# Explictly tell nvcc_wrapper to use the conda-provided 
# g++ as the host compiler
export NVCC_WRAPPER_DEFAULT_COMPILER="${GXX}"

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_CXX_COMPILER=$PREFIX/bin/nvcc_wrapper \
    -DHPG_ENABLE_CUDA=ON \
    -DHPG_ENABLE_SERIAL=ON \
    -DHPG_ENABLE_OPENMP=ON \
    -DFFTW_ROOT_DIR=$PREFIX \
    -DFFTW_INCLUDE_DIR=$PREFIX/include \
    ..

make -j${CPU_COUNT}
make install