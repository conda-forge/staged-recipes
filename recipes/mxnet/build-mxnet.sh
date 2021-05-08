#!/usr/bin/env bash

set -ex

# Use the OpenMP library already in the environment
rm -rf 3rdparty/openmp/

# Use the MKL-DNN library already in the environment
rm -rf 3rdparty/mkldnn
rm -rf include/mkldnn

export OPENMP_OPT=ON

rm -rf build
mkdir build
cd build
cmake \
    -DUSE_SIGNAL_HANDLER=ON                 \
    -DUSE_CUDA=ON                           \
    -DUSE_CUDNN=ON                          \
    -DUSE_TVM_OP=OFF                        \
    -DPython3_EXECUTABLE=python3            \
    -DUSE_MKL_IF_AVAILABLE=OFF              \
    -DUSE_MKLML_MKL=OFF                     \
    -DUSE_MKLDNN=OFF                        \
    -DUSE_DIST_KVSTORE=ON                   \
    -DCMAKE_BUILD_TYPE=Release              \
    -DBUILD_CYTHON_MODULES=1                \
    -G Ninja                                \
..

ninja

