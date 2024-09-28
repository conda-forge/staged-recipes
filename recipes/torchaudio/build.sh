#!/bin/bash
set -ex

if [[ ${cuda_compiler_version} != "None" ]]; then
  # Set the CUDA arch list from
  # https://github.com/conda-forge/pytorch-cpu-feedstock/blob/main/recipe/build_pytorch.sh

  if [[ ${cuda_compiler_version} == 11.8 ]]; then
    export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9+PTX"
    export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
  elif [[ ${cuda_compiler_version} == 12.0 ]]; then
    export TORCH_CUDA_ARCH_LIST="5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX"
    # $CUDA_HOME not set in CUDA 12.0. Using $PREFIX
    export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
  else
    echo "unsupported cuda version. edit build.sh"
    exit 1
  fi

  export USE_ROCM="True"
  export USE_CUDA="True"
  export BUILD_CUDA_CTC_DECODER="True"

else
  export USE_ROCM="False"
  export USE_CUDA="False"
  export BUILD_CUDA_CTC_DECODER="False"
fi

export BUILD_CPP_TEST="False"
export BUILD_SOX="True"
export BUILD_RIR="True"
export BUILD_RNNT="True"
export BUILD_ALIGN="True"
export USE_FFMPEG="True"
export USE_OPENMP="True"

python -m pip install . -vv
