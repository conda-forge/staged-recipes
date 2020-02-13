#!/usr/bin/env bash
set -ex

rm -rf bin/
mkdir -p $PREFIX/bin

pushd make
make -f makefile -j ${CPU_COUNT}
# no make check or make install
cp mf6 $PREFIX/bin/mf6
popd
