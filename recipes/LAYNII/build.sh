#!/usr/bin/env bash

set -e

ln -s "${CXX}" "${BUILD_PREFIX}/bin/c++"
make all

# copy binaries to $PREFIX/bin
mkdir -p $PREFIX/bin
cp LN* $PREFIX/bin/