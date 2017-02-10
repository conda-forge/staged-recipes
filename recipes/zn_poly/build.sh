#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O3 -fPIC $CFLAGS"

if [ "$(uname)" == "Darwin" ]
then
    export CFLAGS="-Wno-unknown-attributes $CFLAGS"
fi

chmod +x configure

./configure --prefix="$SAGE_LOCAL" \
            --cflags="$CFLAGS" --ldflags="$LDFLAGS" \
            --cppflags="$CPPFLAGS" --cxxflags="$CXXFLAGS" \
            --gmp-prefix="$SAGE_LOCAL"

./configure \
        --prefix="$PREFIX" \
        --gmp-prefix="$PREFIX" \
        --cflags="$CFLAGS" \
        --ldflags="$LDFLAGS" \
        --cppflags="$CPPFLAGS" \
        --cxxflags="$CXXFLAGS"

make tune
tune/tune > src/tuning.c
make
make check

if [  "$(uname)" != "Darwin" ]; then
    make libzn_poly.so
else
    make libzn_poly.dylib
fi
make install

