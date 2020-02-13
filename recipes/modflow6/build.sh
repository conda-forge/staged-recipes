#!/usr/bin/env bash
set -ex

rm -rf bin/
mkdir -p $PREFIX/bin

pushd make
# Cannot compile with -j ${CPU_COUNT} due to ordering issues
make -f makefile
# no make check or make install
cp mf6 $PREFIX/bin/mf6
popd
