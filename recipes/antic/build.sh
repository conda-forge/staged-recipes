#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    CXXFLAGS="$CXXFLAGS -fno-common"
fi

./configure --prefix="$PREFIX" --with-gmp="$PREFIX" --with-mpfr="$PREFIX" --with-flint="$PREFIX"

make -j${CPU_COUNT}
make check
make install
