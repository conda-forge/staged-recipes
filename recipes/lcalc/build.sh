#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -fPIC $CFLAGS $CPPFLAGS"
export CXXFLAGS="-g -fPIC $CXXFLAGS $CPPFLAGS"

cd src
make
make install INSTALL_DIR="$PREFIX"

# Delete unnecessary files
rm ${PREFIX}/include/libLfunction/*.crap
rm ${PREFIX}/include/libLfunction/*.bak
