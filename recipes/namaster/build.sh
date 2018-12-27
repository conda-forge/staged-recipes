#!/bin/bash

set -e

if [[ `uname` == 'Darwin' ]]; then
    ./configure --prefix=${PREFIX} LIBS="-lomp"
else
    ./configure --prefix=${PREFIX} LIBS="-lgomp"
fi
make
make install

${PYTHON} -m pip install . -vv --no-deps

# run tests now since they are not around later
make check
