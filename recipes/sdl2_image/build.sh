#!/bin/bash

# Make sure TravisCI can find SDL2
if [ `uname` == Darwin ]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"
fi

./configure --disable-dependency-tracking --enable-imageio=no --prefix=${PREFIX}
make install
