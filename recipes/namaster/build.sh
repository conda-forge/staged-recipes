#!/bin/bash

set -e

if [[ `uname` == 'Darwin' ]] && [[ "$CC" != "clang" ]]; then
    # help anaconda clang link omp on osx
    CFLAGS="$CFLAGS -I${PREFIX}/lib/clang/4.0.1/include"
fi

./configure --prefix=${PREFIX} LIBS="-lgomp"
make
make install

${PYTHON} -m pip install . -vv --no-deps

# run tests now since they are not around later
# make check
