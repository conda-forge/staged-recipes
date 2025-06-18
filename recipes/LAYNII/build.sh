#!/usr/bin/env bash

set -e

make all

# copy binaries to $PREFIX/bin
mkdir -p $PREFIX/bin
cp LN* $PREFIX/bin/