#!/bin/sh

case `uname` in
    Darwin)
	export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib -L$PREFIX/lib"
	;;
    Linux)
	export LDFLAGS="-L$PREFIX/lib -liconv"
	;;
esac
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"

./configure --prefix=$PREFIX \
            --disable-dependency-tracking \
            --disable-silent-rules \
	    --enable-jpeg \
	    --enable-png \
	    --enable-xft

make -j${CPU_COUNT} | sed 's|'$PREFIX'|$PREFIX|g'
make check | sed 's|'$PREFIX'|$PREFIX|g'
make install | sed 's|'$PREFIX'|$PREFIX|g'
