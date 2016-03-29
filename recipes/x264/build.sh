#!/bin/bash

mkdir -vp ${PREFIX}/bin

if [[ `uname` == Darwin ]];
then
    export LD=clang
    export CC=clang
    export CXX=clang++
fi

CFLAGS="-Wall -g -m64 -pipe -O2 -fPIC"
if [[ $ARCH = 64 ]]; then
    CFLAGS="${CFLAGS} -march=x86-64"
else
    CFLAGS="${CFLAGS} -march=i386"
fi
export CFLAGS
export CXXLAGS="${CFLAGS}"

chmod +x configure
./configure \
        --enable-pic \
        --enable-shared \
        --prefix=${PREFIX}
make
make install
