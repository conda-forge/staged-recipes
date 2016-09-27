#!/usr/bin/env bash

if [ `uname` == Darwin ]; then
    ./configure --prefix=$PREFIX --disable-nls --build=i386-apple-darwin11.2.0
else
    ./configure --prefix=$PREFIX --with-glib=embedded --enable-nls=no
fi

make
make install
