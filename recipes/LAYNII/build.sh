#!/usr/bin/env bash

set -e

make CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS -lm" all

# copy binaries to $PREFIX/bin
mkdir -p $PREFIX/bin
cp LN* $PREFIX/bin/
