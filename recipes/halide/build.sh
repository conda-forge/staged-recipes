#!/bin/bash

# On OSX, we need to ensure we're using conda's gcc/g++
if [[ `uname` == Darwin ]]; then
     export CC=gcc
     export LD=gcc
     export CXX=g++
fi

cd python_bindings
mkdir build
cd build
cmake -DHALIDE_LIBRARIES=${HOME}/src/halide-binary/lib -DHALIDE_INCLUDE_DIR=${HOME}/src/halide-binary/include ..
make
