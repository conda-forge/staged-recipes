#!/bin/bash
set -e
set -x

if [ "$(uname)" == "Darwin" ]; then
  #withmpi="--with-mpi=${PREFIX}"
  withmpi=""
  enablefortran="--disable-fortran"
else
  withmpi=""
  enablefortran=""
fi

autoreconf -fi
./configure --prefix="${PREFIX}" \
  ${withmpi} \
  ${enablefortran} \
  --with-hdf5="${PREFIX}" \
  --enable-shared \
  --enable-dagmc \
  --enable-tools \
  || { cat config.log; exit 1; }
make -j "${CPU_COUNT}"
make check
make install
