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
if [ "$(uname)" != "Darwin" ]
then
    # Tests check that the output and expected output are exactly correct
    # leading to errors on OSX when there are small numerical errors
    make check
fi
make install
