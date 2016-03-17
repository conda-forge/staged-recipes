#!/bin/sh

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

libtoolize
aclocal
autoreconf -i

./configure --prefix=$PREFIX   \
            --with-internal-glib

make
make install
