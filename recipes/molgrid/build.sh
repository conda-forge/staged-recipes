#!/bin/bash
set -ex

if [[ ${cuda_compiler_version} != "None" ]]; then
  export USE_CUDA=1
  export NCCL_ROOT_DIR=$PREFIX
  export NCCL_INCLUDE_DIR=$PREFIX/include
  export USE_SYSTEM_NCCL=1
  export USE_STATIC_NCCL=0
  export USE_STATIC_CUDNN=0
  export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
  export CUDNN_INCLUDE_DIR=$PREFIX/include
else
  export USE_CUDA=0
fi

mkdir -p build/
cd build/

cmake ${CMAKE_ARGS} .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX

make -j $CPU_COUNT
make install
