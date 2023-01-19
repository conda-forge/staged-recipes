#!/bin/bash

set -xe

export MPICC=mpicc
export MPICXX=mpicxx
export MPIF77=mpifort
export MPIF90=mpifort

./configure --prefix=${PREFIX} \
    --with-netcdf4=${PREFIX} \
    --enable-shared=yes \
    --enable-static=no

make
# serial tests
make check
# lighter weight parallel tests (4 MPI tasks)
make ptest

make install
