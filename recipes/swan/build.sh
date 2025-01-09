#!/usr/bin/env bash

set -xe

mkdir ${PREFIX}/bin

ln -s ${FC} ${BUILD_PREFIX}/bin/gfortran

FC=gfortran make config

make mpi

install -m 0755 swan.exe ${PREFIX}/bin

unlink ${BUILD_PREFIX}/bin/gfortran