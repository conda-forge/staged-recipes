#! /bin/bash

set -ex

./configure --prefix=$PREFIX --with-cfitsio-prefix=$PREFIX --with-wcslib-include-path=$PREFIX/include/wcslib --with-wcslib-lib-path=$PREFIX/lib --with-gsl-prefix=$PREFIX || { cat config.log ; exit 1 ; }

make
make install

$PYTHON -m pip install -vv --no-deps --ignore-installed .
