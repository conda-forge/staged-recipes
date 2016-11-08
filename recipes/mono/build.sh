#!/usr/bin/env bash

if [ `uname` == Darwin ]; then
    ./configure --prefix=$PREFIX --disable-nls
else
    ./configure --prefix=$PREFIX --with-glib=embedded --enable-nls=no
fi

make V=1
make install
