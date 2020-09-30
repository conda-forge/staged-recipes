#!/usr/bin/env bash
set -ex

./configure \
   "--prefix=${PREFIX}" \
   "--with-flex" \
   "--with-bison"

make
make check
make install
