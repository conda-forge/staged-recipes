#!/bin/bash

set -ex

export CC=mpicc
export CXX=mpicxx
export CFLAGS=-O3

./configure --prefix=$PREFIX 

make -j"${CPU_COUNT}"
make install
