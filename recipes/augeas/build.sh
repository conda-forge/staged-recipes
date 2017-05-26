#!/bin/bash

export CFLAGS=-I$PREFIX/include/
export LIBXML_CFLAGS=-I$PREFIX/include/libxml2/
export LDFLAGS=-L$PREFIX/lib/
export LIBXML_LIBS=-L$PREFIX/lib/
./configure --prefix=$PREFIX
make
make install
