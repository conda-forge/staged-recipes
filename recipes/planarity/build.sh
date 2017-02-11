#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O2 -fPIC $CFLAGS"

chmod +x autogen.sh
./autogen.sh
chmod +x configure
./configure --prefix="$PREFIX"

make
make check
make install
