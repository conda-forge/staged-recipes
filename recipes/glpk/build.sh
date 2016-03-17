#!/bin/bash

export CFLAGS="-O3"
./configure --prefix=$PREFIX --with-gmp

make
make check
make install
