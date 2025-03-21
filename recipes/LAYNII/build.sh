#!/usr/bin/env bash

set -e

make CXXFLAGS="$CXXFLAGS" CC=$CC CFLAGS="$CFLAGS" LFLAGS="$LDFLAGS" all

# copy binaries to $PREFIX/bin
mkdir -p $PREFIX/bin
cp LN* $PREFIX/bin/
