#!/bin/bash

if [[ `uname` == 'Darwin' ]]; then
    # make check below fails on osx unless $PREFIX/lib is added to rpath
    LDFLAGS="$LDFLAGS -Wl,-rpath,${PREFIX}/lib" ./configure
else
    ./configure
fi

make
make check
make install prefix=${PREFIX} exec_prefix=${PREFIX}
