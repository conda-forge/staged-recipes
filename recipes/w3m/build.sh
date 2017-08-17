#!/bin/bash

mkdir -p $PREFIX/bin
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export W3M_LIBS="-lncurses -ltinfo"
./configure --prefix=$PREFIX --with-termlib=ncurses
make
make install
