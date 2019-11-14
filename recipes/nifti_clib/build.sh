#!/bin/sh
make CFLAGS=-I${PREFIX}/include LDFLAGS=-L${PREFIX}/lib CPATH=${PREFIX}/include CC=${CC} nifti
make nifti_install
mv include/* ${PREFIX}/include/
mv lib/* ${PREFIX}/lib/
