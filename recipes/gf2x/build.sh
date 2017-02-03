#!/usr/bin/env bash

autoreconf
chmod +x configure

export CFLAGS="-O2 -g $CFLAGS"
./configure --prefix="$PREFIX" --libdir="$PREFIX"/lib --disable-hardware-specific-code

make
make check
make install
