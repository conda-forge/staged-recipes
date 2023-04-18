#!/bin/bash

if [ -z "${CXX+x}" ]; then echo "Please add the C++ compiler to the environment"; exit 1; fi

export NVCC_PREPEND_FLAGS_BACKUP="${NVCC_PREPEND_FLAGS}"
export NVCC_PREPEND_FLAGS="${NVCC_PREPEND_FLAGS} -ccbin ${CXX}"
