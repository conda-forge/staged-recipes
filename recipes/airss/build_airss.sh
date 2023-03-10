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

airss_bin="${PREFIX}/libexec/airss"
mkdir -p "${airss_bin}"

cp -v \
  src/pp3/src/pp3 \
  src/cabal/src/cabal \
  src/buildcell/src/buildcell \
  src/cryan/src/cryan \
  bin/* \
  "${airss_bin}"

mkdir -p "${PREFIX}/bin"
sed "s;@PREFIX@;${PREFIX};g" "${RECIPE_DIR}/scripts/airss.sh" > "${PREFIX}/bin/airss"
chmod +x "${PREFIX}/bin/airss"
