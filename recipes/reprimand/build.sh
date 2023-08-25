#!/bin/sh

set -e

export BOOST_ROOT=$PREFIX
export MBUILD_DIR=build

mkdir -p $MBUILD_DIR
meson setup --prefix=$PREFIX --libdir=lib -Dbuild_tests=true $MBUILD_DIR
cd $MBUILD_DIR
ninja 
meson test Con2Prim EOS INTERP TOVSOL
ninja install
