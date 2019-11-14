#!/bin/sh

echo "$PREFIX"
ls -al "$PREFIX/include"
make CFLAGS="$CFLAGS -I$PREFIX/include" LDFLAGS="$LDFLAGS -L$PREFIX/lib" CPATH=${PREFIX}/include CC=${CC} nifti
