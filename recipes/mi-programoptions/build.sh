#!/bin/bash

SRC="$SRC_DIR"
BLD=`pwd`
INS="$PREFIX"

cmake \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -Dmi-cpptest_DIR="$PREFIX/lib/cmake/mi-cpptest" \
    -DCMAKE_INSTALL_PREFIX="$INS" \
    "$SRC"

cmake --build "$BLD" --target "all"

export CTEST_OUTPUT_ON_FAILURE="1"
cmake --build "$BLD" --target "test"

cmake --build "$BLD" --target "install"
