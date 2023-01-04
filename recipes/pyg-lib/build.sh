#!/bin/bash
set -ex

if [[ ${cuda_compiler_version} != "None" ]]; then
  export FORCE_CUDA=1
else
  export FORCE_CUDA=0
fi

export USE_MKL_BLAS=1
export Torch_DIR=$(python -c 'import torch; print(torch.utils.cmake_prefix_path)')

export FORCE_NINJA=1
export EXTERNAL_PHMAP_INCLUDE_DIR="${BUILD_PREFIX}/include/"
export EXTERNAL_CUTLASS_INCLUDE_DIR="${BUILD_PREFIX}/include/"

pip install . -vvv
