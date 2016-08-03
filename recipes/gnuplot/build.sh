#!/bin/bash

./configure \
    --prefix=$PREFIX \
    --without-x \
    --without-lua

export GNUTERM=dumb
make
make check
make install
