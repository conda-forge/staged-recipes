#!/bin/bash
set -e
set -x

if [ "$(uname)" == "Darwin" ]; then
  withmpi="--with-mpi=${PREFIX}"
else
  withmpi=""
fi

autoreconf -fi
./configure --prefix="${PREFIX}" \
  ${withmpi} \
  --with-hdf5="${PREFIX}" \
  --enable-shared \
  --enable-dagmc \
  --enable-tools \
  || { cat config.log; exit 1; }
make -j "${CPU_COUNT}"
make check
make install
