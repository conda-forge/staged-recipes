#!/bin/bash

set -ex

export PATH=/usr/local/cuda/bin:
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:
export CUDA_ROOT=/usr/local/cuda/include
export CPATH=$CPATH:/usr/local/cuda/include
export CUDA_INC_DIR=/usr/local/cuda/bin

$PYTHON configure.py --cuda-root=/usr/local/cuda/include
make
make install
