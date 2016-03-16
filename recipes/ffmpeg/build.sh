#!/bin/bash

export CFLAGS="-Wall -g -m64 -pipe -O3 -march=x86-64 -fPIC"
export CXXFLAGS="${CFLAGS}"

if [ "$(uname)" == "Darwin" ];
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [ "$(uname)" == "Linux" ];
then
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

./configure \
        --prefix="${PREFIX}" \
        --enable-shared \
        --enable-pic \
        --enable-libx264 \
        --disable-doc \
        --enable-gpl
make
make install
