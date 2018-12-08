#!/bin/bash

set -e

./configure --prefix=${PREFIX} LIBS="-lgomp"
make
make install

${PYTHON} -m pip install . -vv --no-deps

# run tests now since they are not around later
# make check
