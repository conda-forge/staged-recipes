#!/bin/bash
set -ex

export CFLAGS="$CFLAGS -std=gnu89"

./configure \
    --prefix=$PREFIX \
    --with-tcl=$PREFIX/lib \
    --with-tk=$PREFIX/lib

make
make install

sed -i "1s|#!/bin/bash|#!/usr/bin/env bash|" $PREFIX/bin/netgen
