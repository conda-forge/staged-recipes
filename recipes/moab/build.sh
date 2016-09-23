#!/bin/bash
set -e
set -x

autoreconf -fi
./configure --prefix="${PREFIX}" \
  --with-mpi="${PREFIX}" \
  --with-hdf5="${PREFIX}" \
  --enable-shared \
  --enable-dagmc \
  --enable-tools \
  || { cat config.log; exit 1; }
make -j "${CPU_COUNT}"
make check
make install
