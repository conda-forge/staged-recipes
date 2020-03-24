#!/usr/bin/env bash
set -ex

./configure \
  --prefix="${PREFIX}" \
  --with-libpng="${PREFIX}"

make -j ${CPU_COUNT}
make check
make install
