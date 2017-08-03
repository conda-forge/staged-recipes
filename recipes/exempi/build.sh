#!/bin/bash

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"

if [ $(uname) == Darwin ]; then
	export CXX=clang++
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"
	yesno="no"
fi
if [ $(uname) == Linux ]; then
	export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
	yesno="yes"
fi

./configure --prefix="${PREFIX}" --enable-unittest="$yesno"

make
make check
make install
