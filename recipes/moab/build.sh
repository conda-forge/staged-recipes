#!/bin/bash
set -e
set -x

autoreconf -fi
./configure --prefix=${PREFIX} \
  --with-hdf5 \
  --enable-shared \
  --enable-dagmc \
  || { cat config.log; exit 1; }
make
make check
make install
