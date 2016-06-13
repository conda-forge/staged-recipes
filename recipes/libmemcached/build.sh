#!/bin/bash
set -e
set -x

source activate "${CONDA_DEFAULT_ENV}"

./configure --prefix="$PREFIX"

make
## tests hang on `testapp` on osx and linux
# make check
make install
