#!/bin/bash

export CFLAGS+=-I$PREFIX/include/
export LIBXML_CFLAGS=-I$PREFIX/include/libxml2/
export LDFLAGS+=-L$PREFIX/lib/
export LIBXML_LIBS=-L$PREFIX/lib/

if [ `uname` == Darwin ]; then
    ./configure --prefix=$PREFIX
else
    export LDFLAGS="${LDFLAGS} -Wl,--as-needed"
    ./configure --prefix=$PREFIX
fi

make
make install
