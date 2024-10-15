#!/bin/bash

set -exo pipefail

export TCNN_CUDA_ARCHITECTURES=70,80,90
export CUDA_HOME=$PREFIX
export CMAKE_PREFIX_PATH=$LIBRARY_PREFIX

cd bindings/torch
python -m pip install . -vv --no-deps --no-build-isolation
