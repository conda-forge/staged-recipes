#!/bin/bash

export CFLAGS=-I$PREFIX/include/
export LDFLAGS=-L$PREFIX/lib/

if [ `uname` == Darwin ]; then
  # OSX only
  # If these flags are set on linux build, there's a linking error
  export LIBXML_CFLAGS=-I$PREFIX/include/libxml2/
  export LIBXML_LIBS=-L$PREFIX/lib/
fi
./configure --prefix=$PREFIX
make
make install
