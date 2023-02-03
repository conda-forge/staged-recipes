#!/bin/sh

set -e

export BOOST_ROOT=$BUILD_PREFIX
export MBUILD_DIR=build

mkdir -p $MBUILD_DIR
meson setup --prefix=$PREFIX -Dbuild_tests=true $MBUILD_DIR
cd $MBUILD_DIR
ninja 
ninja install
