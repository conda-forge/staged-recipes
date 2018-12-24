#!/bin/bash

set -o xtrace -o nounset -o pipefail -o errexit

export DISABLE_AUTOBREW=1

# derived from https://github.com/Microsoft/LightGBM/blob/master/build_r.R

# go one level up
cd "$SRC_DIR"
cd ..

# Definition and creation of the build folder
BUILD_DIR="$PWD/build_dir"
mkdir -p "$BUILD_DIR"

# Bring everything in place
cp -r "$SRC_DIR/R-package/./" "$BUILD_DIR/"
cp -r "$SRC_DIR/include" "$BUILD_DIR/src/"
cp -r "$SRC_DIR/src" "$BUILD_DIR/src/"
cp "$SRC_DIR/CMakeLists.txt" "$BUILD_DIR/inst/bin/"

# Build it
cd "$BUILD_DIR"
$R CMD INSTALL --build .
