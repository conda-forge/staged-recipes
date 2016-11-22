#!/usr/bin/env bash

if [ `uname` == Darwin ]; then
    make install PREFIX=$PREFIX CFLAGS="$CFLAGS"
    make check
else    
    # Build binaries    
    make
    make install PREFIX=$PREFIX
    make check
    # Build shared libraries
    make -f Makefile-libbz2_so
    cp -i libbz2.so.* $PREFIX/lib/
fi

