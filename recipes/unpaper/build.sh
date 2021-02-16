#!/bin/bash

aclocal
automake --add-missing
autoconf

./configure --prefix=$PREFIX CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -flto ${CFLAGS}"
make
make install
