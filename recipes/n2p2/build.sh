#!/bin/bash
cd src
export CFLAGS=${CFLAGS}" -isystem $PREFIX/include/eigen3"
make -j${NUM_CPUS} all
make install
