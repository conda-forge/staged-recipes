#!/usr/bin/env bash

make all

# copy binaries to $PREFIX/bin
mkdir -p $PREFIX/bin
cp ./LN* $PREFIX/bin/
