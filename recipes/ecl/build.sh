#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O2 $CFLAGS"

chmod +x configure
./configure \
        --prefix="$PREFIX" \
        --libdir="$PREFIX/lib" \
        --with-gmp-prefix="$PREFIX" \
        --disable-threads \
        --enable-unicode=yes

# Before running make we touch build/TAGS so its building process is never triggered
touch build/TAGS

make
make check
make install

ln -s $PREFIX/lib/ecl-* $PREFIX/lib/ecl
ln -s $PREFIX/include/ecl $PREFIX/lib/ecl/ecl
