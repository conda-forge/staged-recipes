#!/usr/bin/env bash

if [ `uname` == Darwin ]; then
    make install PREFIX=$PREFIX CFLAGS="$CFLAGS"
else
    make -f Makefile-libbz2_so
    make install PREFIX=$PREFIX
    cp -i libbz2.so.* $PREFIX/lib/
fi

#rm -rf $PREFIX/bin $PREFIX/man
