#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O3 $CFLAGS"
export CXXFLAGS="-g -O3 $CXXFLAGS"

chmod +x autogen.sh
./autogen.sh

chmod +x configure
./configure \
    --prefix="$PREFIX" \
    --with-ntl="$PREFIX" \
    --with-pari="$PREFIX" \
    --with-flint="$PREFIX" \
    --with-boost="no" \
    --disable-allprogs

make
make check
make install
