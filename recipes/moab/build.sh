#!/bin/bash
set -e
set -x

if [ "$(uname)" == "Darwin" ]; then
  withmpi="--without-mpi"
else
  withmpi="--with-mpi"
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
