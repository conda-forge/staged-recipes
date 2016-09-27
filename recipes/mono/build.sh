#!/usr/bin/env bash

if [ `uname` == Darwin ]; then
    ./configure --prefix=$PREFIX --disable-nls --build=i386-apple-darwin11.2.0
else
    ./configure --prefix=$PREFIX --with-glib=embedded
fi

make
make install
