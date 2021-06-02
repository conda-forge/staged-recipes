#!/bin/bash

export MPICC=mpicc
export MPICXX=mpicxx
export MPIF77=mpifort
export MPIF90=mpifort

./configure --prefix=${PREFIX} \
    --with-netcdf4=${PREFIX} \
    --enable-shared

make
# serial tests
make check
# lighter weight parallel tests (4 MPI tasks)
make ptest

make install
