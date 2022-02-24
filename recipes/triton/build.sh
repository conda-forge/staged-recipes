#!/bin/bash

set -ex

mkdir build
cd build

# need to communicate with setup.py
export LLVM_LIBRARY_DIR="$PREFIX/lib"
export LLVM_INCLUDE_DIRS="$PREFIX/include"

PYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")

declare -a CMAKE_EXTRA_ARGS
if [ ${cuda_compiler_version} != "None" ]; then
    CMAKE_EXTRA_ARGS+=(
        -DPYTHON_INCLUDE_DIRS="$PYTHON_INCLUDE_DIR;$CUDA_HOME/include"
        -DCUTLASS_LIBRARY_DIR=$PREFIX/lib
        -DCUTLASS_INCLUDE_DIR=$PREFIX/include
    )
else
    CMAKE_EXTRA_ARGS+=(
        -DPYTHON_INCLUDE_DIRS="$PYTHON_INCLUDE_DIR"
    )
fi

cmake \
    ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_PYTHON_MODULE=ON \
    -DLLVM_LIBRARY_DIR=$PREFIX/lib \
    -DLLVM_INCLUDE_DIRS=$PREFIX/include \
    ${CMAKE_EXTRA_ARGS+"${CMAKE_EXTRA_ARGS[@]}"} \
    ..

make
make install

cd ../python
$PYTHON -m pip install . -vv
