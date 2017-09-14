#!/usr/bin/env bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

make std
make std-check
make sse2-check

cp dSFMT.h ${PREFIX}/include
