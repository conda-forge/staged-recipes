#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

BUILD_DIR="$SRC_DIR/build"
BIN_DIR="$PREFIX/bin"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake --trace-expand ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release "$SRC_DIR"
make VERBOSE=1

install --mode 0755 --directory "$BIN_DIR"
install --mode 0755 $SRC_DIR/build/segalign{,_repeat_masker} "$BIN_DIR"
install --mode 0755 $SRC_DIR/scripts/run_segalign{,_repeat_masker} "$BIN_DIR"
