#!/bin/bash

set -x

autoreconf -vfi

export CFLAGS="${CFLAGS} -O3 -g -march=native"

export CC=mpicc
export FC=mpifort

./configure --prefix=${PREFIX} \
            --with-mpi-root=${PREFIX} \
            --without-regard-for-quality \
            --with-pic

make -j ${CPU_COUNT} all
make install
