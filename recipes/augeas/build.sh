#!/bin/bash

export CFLAGS=-I$PREFIX/include/
export LDFLAGS=-L$PREFIX/lib/

if [ `uname` == Darwin ]; then
  # OSX
  export LIBXML_CFLAGS=-I$PREFIX/include/libxml2/
  export LIBXML_LIBS=-L$PREFIX/lib/
fi
./configure --prefix=$PREFIX
make
make install
