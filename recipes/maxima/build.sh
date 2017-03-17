#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O2 $CFLAGS"

if [ "$(uname)" == "Darwin" ]
then
    export CFLAGS="-Wno-unknown-attributes $CFLAGS"
fi

chmod +x configure
./configure \
        --prefix="$PREFIX" \
        --libdir="$PREFIX/lib" \
        --enable-ecl

make
make check || (cat tests/test-suite.log && exit 1)
make install
