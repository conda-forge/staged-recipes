#!/usr/bin/env bash

chmod +x configure

export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

./configure --prefix=$PREFIX --with-gmp-include=$PREFIX/include --with-gmp-lib=$PREFIX/lib --enable-shared
make
make check
make install
