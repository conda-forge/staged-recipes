#!/usr/bin/env bash

set -e

export CC=${CXX}
export CFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

make CC=$CC CFLAGS="$CFLAGS" LFLAGS="$LDFLAGS" all

# copy binaries to $PREFIX/bin
mkdir -p $PREFIX/bin
cp LN* $PREFIX/bin/
