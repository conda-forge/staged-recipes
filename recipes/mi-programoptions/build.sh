#!/bin/bash
set -e

BLD="build"
mkdir -p "$BLD"

cmake -H"$SRC_DIR/source" -B"$BLD" \
     ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_INSTALL_LIBDIR="$PREFIX/lib" \
    -Dmi-cpptest_DIR="$PREFIX/lib/cmake/mi-cpptest"

cmake --build "$BLD" --target "all"

export CTEST_OUTPUT_ON_FAILURE="1"
cmake --build "$BLD" --target "test"

cmake --build "$BLD" --target "install"
