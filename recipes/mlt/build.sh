#!/usr/bin/env bash
set -ex

./configure --prefix="${PREFIX}" \
  --without-kde

make
make check
make install
