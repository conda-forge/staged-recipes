#!/bin/bash

set -ex

export PATH="$PWD:$PATH"


export CC=$(basename $CC)
export CXX=$(basename $CXX)
#export LIBDIR=$PREFIX/lib
#export INCLUDEDIR=$PREFIX/include

#
## clean up an existing cmake build directory
#rm -rf build
#
## uncomment to debug cmake build
export CMAKE_VERBOSE_MAKEFILE=1
#
##export CFLAGS="$(echo $CFLAGS | sed 's/-fvisibility-inlines-hidden//g')"
##export CXXFLAGS="$(echo $CXXFLAGS | sed 's/-fvisibility-inlines-hidden//g')"
##export LDFLAGS="$(echo $LDFLAGS | sed 's/-Wl,--as-needed//g')"
##export LDFLAGS="$(echo $LDFLAGS | sed 's/-Wl,-dead_strip_dylibs//g')"
##export LDFLAGS_LD="$(echo $LDFLAGS_LD | sed 's/-dead_strip_dylibs//g')"
##export CXXFLAGS="$CXXFLAGS -Wno-deprecated-declarations"
##export CFLAGS="$CFLAGS -Wno-deprecated-declarations"
##
##if [[ "$target_platform" == "osx-64" ]]; then
##  export CXXFLAGS="$CXXFLAGS -DTARGET_OS_OSX=1"
##  export CFLAGS="$CFLAGS -DTARGET_OS_OSX=1"
##fi
#
## (from pytorch-feedstock) Dynamic libraries need to be lazily loaded so that torch
## can be imported on system without a GPU
#LDFLAGS="${LDFLAGS//-Wl,-z,now/-Wl,-z,lazy}"
#

if [[ "$target_platform" == "osx-64" ]]; then
  export CXXFLAGS="$CXXFLAGS -DTARGET_OS_OSX=1"
  export CFLAGS="$CFLAGS -DTARGET_OS_OSX=1"
fi

export CMAKE_GENERATOR=Ninja
LDFLAGS="${LDFLAGS//-Wl,-z,now/-Wl,-z,lazy}"

#export CMAKE_LIBRARY_PATH=$PREFIX/lib:$PREFIX/include:$CMAKE_LIBRARY_PATH
#export CMAKE_PREFIX_PATH=$PREFIX
##for ARG in $CMAKE_ARGS; do
##  if [[ "$ARG" == "-DCMAKE_"* ]]; then
##    cmake_arg=$(echo $ARG | cut -d= -f1)
##    cmake_arg=$(echo $cmake_arg| cut -dD -f2-)
##    cmake_val=$(echo $ARG | cut -d= -f2-)
##    printf -v $cmake_arg "$cmake_val"
##    export ${cmake_arg}
##  fi
##done
##unset CMAKE_INSTALL_PREFIX
##export TH_BINARY_BUILD=1
#
#export INSTALL_TEST=0
#export BUILD_TEST=0
#
#
#if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
#    export COMPILER_WORKS_EXITCODE=0
#    export COMPILER_WORKS_EXITCODE__TRYRUN_OUTPUT=""
#fi
#
#
#
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
#
export CMAKE_BUILD_TYPE=Release
#
#echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
#echo "CMAKE_LIBRARY_PATH=$CMAKE_LIBRARY_PATH"

#$PYTHON -m pip install . --no-deps -vvv --no-clean
# we skip deps so opencv-python from pip is not pulled in
$PYTHON -m pip install . -vvv --no-deps
