#!/bin/bash

export LIBXML_CFLAGS=-I$PREFIX/include/libxml2/
export LIBXML_LIBS=-L$PREFIX/lib/

if [ `uname` == Darwin ]; then
    ./configure --prefix=$PREFIX
else
    export LDFLAGS="${LDFLAGS} -Wl,--as-needed"
    ./configure --prefix=$PREFIX
fi

make
make install
