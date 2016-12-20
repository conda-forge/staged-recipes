#!/bin/bash
if [ `uname` == Darwin ]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"
fi

./autogen.sh
./configure --prefix=${PREFIX} --enable-sse --disable-dependency-tracking

make
if [ `uname` == Darwin ]; then
	make check
fi
make install
