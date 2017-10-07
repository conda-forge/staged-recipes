#!/bin/sh

export CFLAGS="-I${PREFIX}/include ${CFLAGS}"
export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"
export LDFLAGS="-L${PREFIX}/lib -L${PREFIX}/include -lintl ${LDFLAGS}"

make
make install prefix=$PREFIX

# rename to prevent collision with system (BSD) getopt on OSX
mv $PREFIX/bin/getopt $PREFIX/bin/gnu-getopt