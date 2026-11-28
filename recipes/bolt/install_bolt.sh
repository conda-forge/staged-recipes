#!/bin/bash
set -ex

# temporary prefix to be able to install files more granularly
mkdir temp_prefix

if [[ "${PKG_NAME}" == "libbolt-devel" ]]; then
    cmake --install ./build --prefix=./temp_prefix
    mv ./temp_prefix/lib/libLLVMBOLT* $PREFIX/lib
    # only on linux-64
    mv ./temp_prefix/lib/libbolt* $PREFIX/lib || true
    # move CMake metadata
    mv ./temp_prefix/lib/cmake/llvm/* $PREFIX/lib/cmake/llvm/
    # unclear which headers belong to bolt, but if some are there, install
    mv ./temp_prefix/include/* $PREFIX/include/
else
    # bolt: install everything else
    cmake --install ./build --prefix=$PREFIX
fi

rm -rf temp_prefix
