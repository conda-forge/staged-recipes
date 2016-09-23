#!/bin/bash
set -e
set -x

autoreconf -fi
./configure --prefix="${PREFIX}" \
  --with-hdf5="${PREFIX}" \
  --enable-shared \
  --enable-dagmc \
  --enable-tools \
  || { cat config.log; exit 1; }
make
make check
make install
