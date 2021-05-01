#!/bin/bash

export MPICC=mpicc
export MPICXX=mpicxx
export MPIF77=mpifort
export MPIF90=mpifort

./configure --prefix=${PREFIX} \
    --with-netcdf4=${PREFIX} \
    --enable-shared

make
make install
