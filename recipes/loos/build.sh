#!/bin/sh
# This install script is intended for conda-forge, and assumes the conda env
# is already set up. If you need to set up a conda env, I suggest running
# conda_build.sh instead.


if [ "$platform" = "Linux" ]; then
    export CXX=`which g++`
elif [ "$platform" = 'Darwin' ]; then
    export CXX=`which clang++`
else
    echo "Unknown platform $platform, assuming g++"
    export CXX=`which g++`
fi
echo "CXX set to $CXX"

scons PREFIX=$CONDA_PREFIX
scons PREFIX=$CONDA_PREFIX install
