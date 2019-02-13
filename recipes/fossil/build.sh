#!/usr/bin/env bash
set -eux
./configure \
  --prefix=$PREFIX \
  --debug \
  --disable-internal-sqlite \
  --with-tcl=$PREFIX \
  --with-zlib=$PREFIX/include \
  --with-openssl=$PREFIX \
  --json
make --debug
make install --debug
