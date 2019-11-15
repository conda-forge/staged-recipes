#!/usr/bin/env bash
set -ex

./configure --prefix="${PREFIX}" \
  --without-kde

make
# no make check
make install
