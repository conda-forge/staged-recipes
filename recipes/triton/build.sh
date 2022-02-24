#!/bin/bash

set -ex

mkdir build
cd build

# need to communicate with setup.py
export LLVM_LIBRARY_DIR="$PREFIX/lib"
export LLVM_INCLUDE_DIRS="$PREFIX/include"

declare -a CMAKE_EXTRA_ARGS
if [ ${cuda_compiler_version} != "None" ]; then
    CMAKE_EXTRA_ARGS+=(
        -DPYTHON_INCLUDE_DIRS="$PREFIX/include;$CUDA_HOME/include"
        -DCUTLASS_LIBRARY_DIR=$PREFIX/lib
        -DCUTLASS_INCLUDE_DIR=$PREFIX/include
    )
else
    CMAKE_EXTRA_ARGS+=(
        -DPYTHON_INCLUDE_DIRS="-DPYTHON_INCLUDE_DIRS=$PREFIX/include"
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
