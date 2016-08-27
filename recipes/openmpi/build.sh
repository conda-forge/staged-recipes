#!/bin/bash

OPTS=""
if [[ $(uname) == Darwin ]]; then
    OPTS="--disable-mpi-fortran"
fi

./configure --prefix=$PREFIX $OPTS
make
make check
make install
