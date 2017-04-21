#!/bin/bash

config_args="--enable-shared"
if [[ `uname` == 'Darwin' ]]; then
    # make check below fails on osx unless $PREFIX/lib is added to rpath
    LDFLAGS="$LDFLAGS -Wl,-rpath,${PREFIX}/lib" ./configure ${config_args}
else
    ./configure ${config_args}
fi

make
make check
make install prefix=${PREFIX} exec_prefix=${PREFIX}
