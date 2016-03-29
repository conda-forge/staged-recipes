#!/bin/bash

# cannot build flann from within the source directory
mkdir build
cd build

# On OSX, we need to ensure we're using conda's gcc/g++
if [[ `uname` == Darwin ]]; then
    export CC=gcc
    export LD=gcc
    export CXX=g++
fi

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_MATLAB_BINDINGS:BOOL=OFF -DBUILD_PYTHON_BINDINGS:BOOL=OFF -DBUILD_EXAMPLES:BOOL=OFF

make install
