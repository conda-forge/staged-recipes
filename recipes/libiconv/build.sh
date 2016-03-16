#!/bin/sh

export CFLAGS="-fPIC"

./configure --prefix=${PREFIX}
make
make check
make install
