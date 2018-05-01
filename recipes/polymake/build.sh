#!/bin/bash
export CXXFLAGS="-I$PREFIX/include $CXXFLAGS"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PREFIX/lib"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"

if [[ $(uname) == 'Darwin' ]]; then
    ./configure --prefix=$PREFIX --without-lrs --without-fink
else
    ./configure --prefix=$PREFIX --without-lrs
fi

ninja -C build/Opt install
