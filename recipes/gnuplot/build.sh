#!/bin/bash

opts="
    --without-x \
    --without-lua \
    --without-latex \
    --without-libcerf \
    --with-qt \
    --with-readline=$PREFIX
    "

LDFLAGS="-Wl,-rpath,$PREFIX/lib $LDFLAGS" LIBS="-liconv" ./configure --prefix=$PREFIX $opts

export GNUTERM=dumb
make PREFIX=$PREFIX
make check PREFIX=$PREFIX
make install PREFIX=$PREFIX
