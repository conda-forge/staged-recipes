#!/bin/bash

./configure LIBXML_CFLAGS=-I$PREFIX/include/libxml2/ LIBXML_LIBS=-L$PREFIX/lib/
make
make install
