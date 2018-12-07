#!/bin/bash

set -e

./configure --prefix=${PREFIX}
make
make install

# run tests now since it is not around later
make check

${PYTHON} -m pip install . -vv --no-deps
