#!/bin/bash

export CPPFLAGS="-I$PREFIX/include -DDISABLE_COMMENTATOR $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-O2 -g -fPIC $CFLAGS"
export CXXFLAGS="-O2 -g -fPIC $CXXFLAGS"

if [ "$(uname)" == "Darwin" ]
then
    # turn off annoying wrnings
    export CFLAGS="-Wno-deprecated-register $CFLAGS"
    export CXXFLAGS="-Wno-deprecated-register $CXXFLAGS"
fi

chmod +x configure

./configure \
    --prefix="$PREFIX" \
    --with-giac=no \
    --libdir="$PREFIX/lib"

make -j${CPU_COUNT}
make install
