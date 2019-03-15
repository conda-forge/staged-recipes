#!/bin/bash
set -ex

autoreconf -ivf
./configure --prefix="${PREFIX}" \
  --enable-shared \
  --disable-static \
  --with-pic
make -j "${CPU_COUNT}"
make check
make test
make install
