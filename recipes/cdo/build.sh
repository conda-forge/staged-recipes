#!/bin/bash

export CPPFLAGS=-I$PREFIX/include
export LDFLAGS=-L$PREFIX/lib
./configure --prefix=$PREFIX \
            --disable-debug \
            --disable-dependency-tracking \
            --with-jasper=$PREFIX \
            --with-hdf5=$PREFIX \
            --with-netcdf=$PREFIX \
            --with-proj=$PREFIX

make
if [[ $(uname) == Linux ]]; then
    make check
fi
make install
