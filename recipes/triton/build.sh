#!/bin/bash

set -ex

# need to communicate with setup.py
export LLVM_LIBRARY_DIR="$PREFIX/lib"
export LLVM_INCLUDE_DIRS="$PREFIX/include"

cd python
$PYTHON -m pip install . -vv
