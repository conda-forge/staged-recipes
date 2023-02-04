#!/bin/sh

set -e

export BOOST_ROOT=$PREFIX
export MBUILD_DIR=build

mkdir -p $MBUILD_DIR
meson setup --prefix=$PREFIX --libdir=lib $MBUILD_DIR
cd $MBUILD_DIR
ninja 
ninja install
