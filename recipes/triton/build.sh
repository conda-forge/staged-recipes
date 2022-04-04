#!/bin/bash

set -ex

# need to communicate with setup.py
export LLVM_LIBRARY_DIR="$PREFIX/lib"
export LLVM_INCLUDE_DIRS="$PREFIX/include"

# remove outdated vendored headers
rm -rf $SRC_DIR/include/triton/external/CUDA

cd python
$PYTHON -m pip install . -vv
