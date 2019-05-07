#!/bin/bash

export NCCL_LIB_DIR="${PREFIX}/lib"
export NCCL_INCLUDE_DIR="${PREFIX}/include"

python setup.py install --single-version-externally-managed --record record.txt
