#!/bin/sh
make CFLAGS=-I${PREFIX}/include LDFLAGS=-L${PREFIX}/lib CPATH=${PREFIX}/include CC=${CC} nifti
