#!/bin/bash

if [ `uname` == Darwin ]; then
	export CC=clang
	export CXX=clang++
fi

./configure --prefix=$PREFIX \
--disable-network \
--disable-static
make
make install

