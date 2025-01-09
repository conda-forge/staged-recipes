#!/usr/bin/env bash

set -xe

mkdir -p ${PREFIX}/bin ${BUILD_PREFIX}/bin/

ln -s ${FC} ${BUILD_PREFIX}/bin/gfortran
ln -s ${CC} ${BUILD_PREFIX}/bin/gcc


FC=gfortran NETCDFROOT=${PREFIX} make config

cat macros.inc

FFLAGS="${FFLAGS} -fno-second-underscore -fallow-argument-mismatch" \
    FFLAGS90="${FFLAGS} -fno-second-underscore -fallow-argument-mismatch -ffree-line-length-none" \
    make mpi

install -m 0755 swan.exe ${PREFIX}/bin
install -m 0755 swanrun ${PREFIX}/bin

unlink ${BUILD_PREFIX}/bin/gfortran