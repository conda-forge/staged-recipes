#!/bin/bash

set -ex

cmake \
    -DCMAKE_CUDA_COMPILER=$CONDA_PREFIX/bin/nvcc
    -DBUILD_TEST=TRUE \
    -DWITH_ZMQ=TRUE \
    .

# compile
make -j$CPU_COUNT

cd build/python

# why -e ...?
pip install -e .
