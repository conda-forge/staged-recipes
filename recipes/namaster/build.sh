#!/bin/bash

set -e

if [[ `uname` == 'Darwin' ]] && [[ "$CC" != "clang" ]]; then
    # help anaconda clang link omp on osx
    CFLAGS="$CFLAGS -I${PREFIX}/lib/clang/4.0.1/include"
fi

if [[ `uname` == 'Darwin' ]]; then
    ./configure --prefix=${PREFIX} LIBS="-lomp"
else
    ./configure --prefix=${PREFIX} LIBS="-lgomp"
fi
make
make install

${PYTHON} -m pip install . -vv --no-deps

# run tests now since they are not around later
# make check
