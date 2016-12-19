#!/bin/bash

if [ `uname` == Darwin ]; then
	EXTRA_FLAGS=--disable-oggtest
fi

./configure --prefix=${PREFIX} --disable-dependency-tracking ${EXTRA_FLAGS}
make 
make check
make install
