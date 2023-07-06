#!/bin/bash

set -xe

export MPICC=mpicc
export MPICXX=mpicxx
export MPIF77=mpifort
export MPIF90=mpifort

./configure --prefix=${PREFIX} \
    --with-mpi=${PREFIX} \
    --enable-shared=yes \
    --enable-static=no

make

# MPI tests aren't working in CI (not uncommon)
# make check
# make ptest

make install
