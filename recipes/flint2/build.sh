#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"

chmod +x configure

./configure --prefix=$PREFIX --with-gmp=$PREFIX --with-mpfr=$PREFIX

make

# Travis timeouts when running tests on OS X.
if [ "$(uname)" == "Linux" ]
then
    make check
fi

make install

