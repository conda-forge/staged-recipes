#!/bin/sh

case `uname` in
    Darwin)
	export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
	;;
    Linux)
	export LDFLAGS="-L$PREFIX/lib -liconv"
	;;
esac

./configure --prefix=$PREFIX \
            --disable-dependency-tracking \
            --disable-silent-rules \
	    --enable-jpeg \
	    --enable-png \
	    --enable-xft



make -j${CPU_COUNT}
make install
