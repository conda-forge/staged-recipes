#!/bin/bash
set -ex

# Deepspeed ops cannot be built without CUDA
if [[ ${cuda_compiler_version} != "None" ]]; then
  export DS_BUILD_OPS=1

  # Set the CUDA arch list from
  # https://github.com/conda-forge/pytorch-cpu-feedstock/blob/2be0b38024b3b5601fcefce40596fc2a5fce4ab7/recipe/build_pytorch.sh#L94

  lif [[ ${cuda_compiler_version} == 10.* ]]; then
    export TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5+PTX"
  elif [[ ${cuda_compiler_version} == 11.0* ]]; then
    export TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0+PTX"
  elif [[ ${cuda_compiler_version} == 11.1 ]]; then
    export TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0;8.6+PTX"
  elif [[ ${cuda_compiler_version} == 11.2 ]]; then
    export TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0;8.6+PTX"
  else
    echo "Unsupported cuda version. edit build.sh"
    exit 1
  fi

else
  export DS_BUILD_OPS=0
fi

# Disable sparse_attn since it requires an exact version of triton==1.0.0
export DS_BUILD_SPARSE_ATTN=0

python -m pip install . -vv
