#!/usr/bin/env bash

if [ `uname` == Darwin ]; then
    make install PREFIX=$PREFIX CFLAGS="$CFLAGS"
    make check
else    
    # Build binaries    
    make
    make check
    # Build shared libraries
    make -f Makefile-libbz2_so
    make install PREFIX=$PREFIX
    cp -i libbz2.so.* $PREFIX/lib/
fi

