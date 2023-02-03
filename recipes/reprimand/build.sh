#!/bin/sh

set -e

export BUILD_DIR=build
mkdir -p $BUILD_DIR
meson setup --prefix=$PREFIX -Dbuild_tests=true $BUILD_DIR
cd $BUILD_DIR
ninja 
ninja install
