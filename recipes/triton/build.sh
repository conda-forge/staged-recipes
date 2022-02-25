#!/bin/bash

set -ex

# need to communicate with setup.py
export LLVM_LIBRARY_DIR="$PREFIX/lib"
export LLVM_INCLUDE_DIRS="$PREFIX/include"

if [ ${cuda_compiler_version} != "None" && ${cuda_compiler_version} != "10.2" ]; then
    export CUTLASS_LIBRARY_DIR=$PREFIX/lib
    export CUTLASS_INCLUDE_DIR=$PREFIX/include
fi

cd python
$PYTHON -m pip install . -vv
