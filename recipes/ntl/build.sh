#!/usr/bin/env bash

cd src
chmod +x configure

export CFLAGS="-O2 -g $CFLAGS"
export CXXFLAGS="-O2 -g $CXXFLAGS"

if [ "$(uname)" == "Darwin" ]; then
    CXXFLAGS="$CXXFLAGS -fno-common"
fi

./configure DEF_PREFIX="$PREFIX" SHARED=on \
        CXXFLAGS="$CXXFLAGS" \
        NTL_GMP_LIP=on \
        NTL_GF2X_LIB=on \
        NATIVE=off \
        NTL_THREADS=off

make
make check
make install

