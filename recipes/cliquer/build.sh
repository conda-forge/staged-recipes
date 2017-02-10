#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-O2 -g $CFLAGS"

autoreconf -fi
automake --add-missing --copy
chmod +x configure
./configure --prefix="$PREFIX" --libdir="$PREFIX/lib"

make
make check
make install
