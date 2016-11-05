#!/bin/sh
set -x -e

export PATH=${PREFIX}/bin:$PATH
export INCLUDE_PATH="${PREFIX}/include"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CPATH="${PREFIX}/include"

export LIBDIR="${PREFIX}/lib"

if [ `uname -m` == Darwin ]; then
    export LIBTOOLIZE="${PREFIX}/bin/libtoolize"
fi

ln -s ${PREFIX}/bin/libtoolize ${PREFIX}/bin/glibtoolize

make
make install
