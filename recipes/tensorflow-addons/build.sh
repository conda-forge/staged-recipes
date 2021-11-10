#!/bin/bash

set -ex

export PATH="$PWD:$PATH"
export CC=$(basename $CC)
export CXX=$(basename $CXX)
export LIBDIR=$PREFIX/lib
export INCLUDEDIR=$PREFIX/include

export TF_NEED_CUDA=0

if [[ ${cuda_compiler_version} != "None" ]]; then
    export TF_NEED_CUDA=1
    export TF_CUDA_PATHS="${PREFIX},${CUDA_HOME}"
    export TF_CUDA_VERSION="${cuda_compiler_version}"
    export TF_CUDNN_VERSION="${cudnn}"
    export CUDA_TOOLKIT_PATH="${CUDA_HOME}"
    export CUDNN_INSTALL_PATH="${PREFIX}"

    if [[ ${cuda_compiler_version} == 10.* ]]; then
        export TF_CUDA_COMPUTE_CAPABILITIES=sm_35,sm_50,sm_60,sm_62,sm_70,sm_72,sm_75,compute_75
    elif [[ ${cuda_compiler_version} == 11.0* ]]; then
        export TF_CUDA_COMPUTE_CAPABILITIES=sm_35,sm_50,sm_60,sm_62,sm_70,sm_72,sm_75,sm_80,compute_80
    elif [[ ${cuda_compiler_version} == 11.1 ]]; then
        export TF_CUDA_COMPUTE_CAPABILITIES=sm_35,sm_50,sm_60,sm_62,sm_70,sm_72,sm_75,sm_80,sm_86,compute_86
    elif [[ ${cuda_compiler_version} == 11.2 ]]; then
        export TF_CUDA_COMPUTE_CAPABILITIES=sm_35,sm_50,sm_60,sm_62,sm_70,sm_72,sm_75,sm_80,sm_86,compute_86
    else
        echo "unsupported cuda version."
        exit 1
    fi
fi

# This script links project with TensorFlow dependency
python ./configure.py

bazel build build_pip_pkg
# build a whl file
mkdir -p $SRC_DIR/tf_addons_pkg
bash -x bazel-bin/build_pip_pkg $SRC_DIR/tf_addons_pkg

pip install tf_addons_pkg/tensorflow_addons-*.whl
