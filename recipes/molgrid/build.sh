#!/bin/bash
set -ex

# hack for now: https://github.com/conda-forge/pyquaternion-feedstock/pull/1
pip install https://github.com/KieranWynn/pyquaternion/archive/refs/tags/v0.9.9.tar.gz

NUMPY_INCLUDE_DIR=$(python -c "import numpy; print(numpy.get_include())")

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
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DOPENBABEL3_INCLUDE_DIR=$PREFIX/include/openbabel3/ \
  -DOPENBABEL3_LIBRARIES=$PREFIX/lib/libopenbabel.so \
  -DPYTHON_NUMPY_INCLUDE_DIR=$NUMPY_INCLUDE_DIR \
  -DBUILD_STATIC=0

make -j $CPU_COUNT
make install
