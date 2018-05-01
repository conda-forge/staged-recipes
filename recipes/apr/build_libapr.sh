#!/bin/bash

cd apr
./configure \
        --prefix="${PREFIX}" \
        --enable-shared \
        --enable-static \
        --with-pic \

make
#make check
make install
