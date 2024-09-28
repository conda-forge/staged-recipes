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

  export USE_ROCM="true"
  export USE_CUDA="true"
  export BUILD_CUDA_CTC_DECODER="true"

else
  export USE_ROCM="false"
  export USE_CUDA="false"
  export BUILD_CUDA_CTC_DECODER="false"
fi

export BUILD_CPP_TEST="false"
export BUILD_SOX="true"
export BUILD_RIR="true"
export BUILD_RNNT="true"
export BUILD_ALIGN="true"
export USE_FFMPEG="true"
export USE_OPENMP="true"

export CMAKE_C_COMPILER="$CC"
export CMAKE_CXX_COMPILER="$CXX"
export CMAKE_GENERATOR="Ninja"

python -m pip install . -vv
