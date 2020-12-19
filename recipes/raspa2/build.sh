#!/bin/bash

mkdir m4
aclocal
autoreconf -i
automake --add-missing
autoconf
./configure --prefix=${PREFIX}
make
make install
