#!/bin/sh -x
# This install script is intended for conda-forge, and assumes the conda env
# is already set up. If you need to set up a conda env, I suggest running
# conda_build.sh instead.
set -x

#if [ "$platform" = "Linux" ]; then
#    export CXX=`which g++`
#elif [ "$platform" = 'Darwin' ]; then
#    export CXX=`which clang++`
#else
#    echo "Unknown platform $platform, assuming g++"
#    export CXX=`which g++`
#fi
echo "Begin loos build.sh"
export CXX=x86_64-conda_cos6-linux-gnu-c++
which $CXX
export CONDA_PREFIX=$BUILD_PREFIX

scons PREFIX=$CONDA_PREFIX
scons PREFIX=$CONDA_PREFIX install
