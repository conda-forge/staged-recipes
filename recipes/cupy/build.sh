#!/bin/bash

export CFLAGS="${CFLAGS} -I${CUDA_HOME}/include"
export NCCL_LIB_DIR="${PREFIX}/lib"
export NCCL_INCLUDE_DIR="${PREFIX}/include"

python setup.py install --single-version-externally-managed --record record.txt
