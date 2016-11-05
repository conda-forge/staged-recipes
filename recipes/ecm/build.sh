#!/usr/bin/env bash

chmod +x configure

./configure --prefix=$PREFIX --with-gmp-include=$PREFIX/include --with-gmp-lib=$PREFIX/lib --enable-shared
make
make check
make install
