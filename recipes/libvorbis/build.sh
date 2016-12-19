#!/bin/bash

if [ `uname` == Darwin ]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"
fi

./configure --prefix=${PREFIX} --disable-dependency-tracking
make 
make check
make install
