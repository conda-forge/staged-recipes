#!/bin/bash
set -ex

git submodule sync --recursive
git submodule update --init --recursive

if [[ ${cuda_compiler_version} != "None" ]]; then
  export WITH_CUDA=ON
  export FORCE_CUDA=1
  export CUDA_ARCH_LIST=75
else
  export WITH_CUDA=OFF
  export FORCE_CUDA=0
fi

export USE_MKL_BLAS=1
export Torch_DIR=$(python -c 'import torch; print(torch.utils.cmake_prefix_path)')

pip install . -vvv
