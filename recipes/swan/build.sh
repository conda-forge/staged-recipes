#!/usr/bin/env bash

set -xe

mkdir -p ${PREFIX}/bin ${BUILD_PREFIX}/bin/

ln -s ${FC} ${BUILD_PREFIX}/bin/gfortran

FC=gfortran make config

make mpi

install -m 0755 swan.exe ${PREFIX}/bin
install -m 0755 swanrun ${PREFIX}/bin

unlink ${BUILD_PREFIX}/bin/gfortran