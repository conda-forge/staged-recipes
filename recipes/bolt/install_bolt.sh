#!/bin/bash
set -ex

# temporary prefix to be able to install files more granularly
mkdir temp_prefix

if [[ "${PKG_NAME}" == "libbolt-devel" ]]; then
    cmake --install ./build --prefix=./temp_prefix
    # only bolt libraries
    mkdir -p $PREFIX/lib/cmake/llvm
    mv ./temp_prefix/lib/libLLVMBOLT* $PREFIX/lib
    # only on linux-64
    mv ./temp_prefix/lib/libbolt* $PREFIX/lib || true
    # copy CMake metadata
    mv ./temp_prefix/lib/cmake/llvm $PREFIX/lib/cmake/llvm
else
    # bolt: install everything else
    cmake --install ./build --prefix=$PREFIX
fi

rm -rf temp_prefix
