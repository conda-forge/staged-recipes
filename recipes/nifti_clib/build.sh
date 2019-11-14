#!/bin/sh
make CFLAGS=-I${PREFIX}/include LDFLAGS=-L${PREFIX}/lib CC=${CC} all
mv include/* ${PREFIX}/include/
mv lib/* ${PREFIX}/lib/
