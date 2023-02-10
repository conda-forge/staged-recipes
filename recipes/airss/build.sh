#!/usr/bin/env bash

set -ex

LIBS="-llapack -lblas -lsymspg"

make \
  FC="$FC" \
  FFLAGS="$FFLAGS" \
  CC="$CC" \
  CFLAGS="$CFLAGS" \
  LDFLAGS="$LDFLAGS $LIBS" \
  all

mkdir -p "$PREFIX/bin"

cp -v \
  src/pp3/src/pp3 \
  src/cabal/src/cabal \
  src/buildcell/src/buildcell \
  src/cryan/src/cryan \
  external/symmol/symmol \
  bin/* \
  "$PREFIX/bin"
