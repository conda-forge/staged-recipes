#!/bin/bash

set -e -o pipefail

ln -s $PREFIX/lib $PREFIX/lib64

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig:/usr/lib64/pkgconfig:/usr/share/pkgconfig"
export ACLOCAL_FLAGS="-I$PREFIX/share/aclocal"

if  [[ "$OSTYPE" == "darwin"* ]]; then
  ./configure  --prefix=$PREFIX --enable-introspection=yes CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib -Wl,-rpath ${PREFIX}/lib" 
else
  ./configure  --prefix=$PREFIX --enable-introspection=yes CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
fi

make
make install
