#! /bin/bash

set -e

if [ -n "$OSX_ARCH" ] ; then
    export CXXFLAGS="$CXXFLAGS -stdlib=libc++"
else
    export CFLAGS="$CFLAGS -I$PREFIX/include"
    export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
    export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
fi

./configure --prefix=$PREFIX --disable-ecore --disable-tests --disable-examples || { cat config.log ; exit 1 ; }
make
make install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
