#!/bin/bash

set -ex

export PATH=/usr/local/cuda/bin
export CUDA_ROOT=/usr/local/cuda/include
export CPATH=$CPATH:/usr/local/cuda/include
export CUDA_INC_DIR=/usr/local/cuda/bin
export CUDA_HOME=/usr/local/cuda
export C_INCLUDE_PATH=${CUDA_HOME}/include:${C_INCLUDE_PATH}
export LIBRARY_PATH=${CUDA_HOME}/lib64:$LIBRARY_PATH

$PYTHON configure.py --cuda-root=/usr/local/cuda/include
$PYTHON setup.py build
$PYTHON setup.py install --single-version-externally-managed --record record.txt
