#!/bin/bash

set -exo pipefail

export TCNN_CUDA_ARCHITECTURES=70,80,90
export CUDA_HOME=$PREFIX
export CMAKE_PREFIX_PATH=$PREFIX

cd bindings/torch
${PYTHON} -m pip install . -vv
