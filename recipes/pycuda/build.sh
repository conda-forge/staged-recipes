#!/bin/bash

set -ex

export PATH=/usr/local/cuda
export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64\
         ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export CUDA_ROOT=/usr/local/cuda/include
export CPATH=$CPATH:/usr/local/cuda/include
export CUDA_INC_DIR=/usr/local/cuda/bin:$CUDA_INC_DIR

python setup.py build
sudo python setup.py install
