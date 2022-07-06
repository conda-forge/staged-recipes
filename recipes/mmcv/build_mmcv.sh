#!/bin/bash

set -ex

export PATH="$PWD:$PATH"


export CC=$(basename $CC)
export CXX=$(basename $CXX)

# uncomment for debug
# export CMAKE_VERBOSE_MAKEFILE=1

if [[ "$target_platform" == "osx-64" ]]; then
  export CXXFLAGS="$CXXFLAGS -DTARGET_OS_OSX=1"
  export CFLAGS="$CFLAGS -DTARGET_OS_OSX=1"
fi

export CMAKE_GENERATOR=Ninja
LDFLAGS="${LDFLAGS//-Wl,-z,now/-Wl,-z,lazy}"
export MAX_JOBS=${CPU_COUNT}
export MMCV_WITH_OPS=1

if [[ ${cuda_compiler_version} != "None" ]]; then
    export FORCE_CUDA="1"
    export CUDA_HOME="/usr/local/cuda"
    export CUDA_PATH=$CUDA_HOME
    export PATH="$CUDA_HOME/bin:$PATH"
    export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
    if [[ ${cuda_compiler_version} == 9.0* ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;7.0+PTX"
    elif [[ ${cuda_compiler_version} == 9.2* ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0+PTX"
    elif [[ ${cuda_compiler_version} == 10.* ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5+PTX"
    elif [[ ${cuda_compiler_version} == 11.0* ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0+PTX"
    elif [[ ${cuda_compiler_version} == 11.1 ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX"
    elif [[ ${cuda_compiler_version} == 11.2 ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX"
    else
        echo "unsupported cuda version. edit build_mmcv.sh"
        exit 1
    fi
fi

export CMAKE_BUILD_TYPE=Release
# we skip deps so opencv-python from pip is not pulled in
$PYTHON -m pip install . -vvv --no-deps
