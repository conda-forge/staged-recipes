#!/bin/bash
export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PREFIX/lib"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"

./configure --prefix=$PREFIX --without-lrs --without-fink
ninja -c build/Opt install
