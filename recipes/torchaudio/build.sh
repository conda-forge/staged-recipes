#!/bin/bash
set -ex

if [[ ${cuda_compiler_version} != "None" ]]; then
  # Set the CUDA arch list from
  # https://github.com/conda-forge/pytorch-cpu-feedstock/blob/main/recipe/build_pytorch.sh
  CMAKE_ARGS+=" -DCMAKE_CUDA_HOST_COMPILER=\${CXX}"

  if [[ ${cuda_compiler_version} == 11.8 ]]; then
    export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9+PTX"
    export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
  elif [[ ${cuda_compiler_version} == 12.0 ]]; then
    export TORCH_CUDA_ARCH_LIST="5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX"
    # $CUDA_HOME not set in CUDA 12.0. Using $PREFIX
    export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
    # CUDA_HOME must be set for the build to work in torchaudio
    export CUDA_HOME="${PREFIX}"
  else
    echo "unsupported cuda version. edit build.sh"
    exit 1
  fi

  export USE_CUDA=1
  export BUILD_CUDA_CTC_DECODER=1
else
  export USE_CUDA=0
  export BUILD_CUDA_CTC_DECODER=0
fi

export USE_ROCM=0
export USE_OPENMP=1
export BUILD_CPP_TEST=0

# sox is buggy
export BUILD_SOX=0
# FFMPEG is buggy
# export FFMPEG_ROOT="${PREFIX}"
export USE_FFMPEG=0
# RNNT loss is buggy
export BUILD_RNNT=0

export CMAKE_C_COMPILER="$CC"
export CMAKE_CXX_COMPILER="$CXX"
export CMAKE_GENERATOR="Ninja"

python -m pip install . -vv
