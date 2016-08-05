#!/bin/bash

opts="
    --without-x \
    --without-lua \
    --without-latex \
    --without-libcerf \
    --with-qt4
    "

opts="$opts --with-readline=$PREFIX"

LIBS="-liconv" ./configure --prefix=$PREFIX $opts

export GNUTERM=dumb
make PREFIX=$PREFIX
make check PREFIX=$PREFIX
make install PREFIX=$PREFIX
