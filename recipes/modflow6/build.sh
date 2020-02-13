#!/usr/bin/env bash
set -ex

export CFLAGS="$CFLAGS $LDFLAGS -D_UF"
export FFLAGS="$FFLAGS $LDFLAGS -fbacktrace"

rm -rf bin/
mkdir -p $PREFIX/bin

pushd make
# Cannot compile with -j ${CPU_COUNT} due to ordering issues
make -f makefile
# no make check or make install
cp mf6 $PREFIX/bin/mf6
popd
