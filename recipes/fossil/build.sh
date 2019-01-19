#!/usr/bin/env bash
set -eux
./configure \
  --disable-internal-sqlite \
  --with-tcl-private-stubs=1 \
  --with-tcl=1 \
  --prefix=$PREFIX
make
make install
