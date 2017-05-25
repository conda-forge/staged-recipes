#!/bin/bash

./configure LIBXML_CFLAGS=-I$PREFIX/include LIBXML_LIBS=-L$PREFIX/lib/
make
make install
