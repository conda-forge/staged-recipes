#!/usr/bin/env bash

export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

if [ "$(uname)" == "Linux" ]
then
    autoconf
fi

chmod +x configure
./configure --prefix=$PREFIX --with-gmp-include=$PREFIX/include --with-gmp-lib=$PREFIX/lib --enable-shared

make

chmod +x test.pp1
chmod +x test.pm1
chmod +x test.ecm
make check

make install
