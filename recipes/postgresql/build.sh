#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # At first attempt, openssl-enabled fails to build on Mac.  Needs further investigation.
    ./configure --without-readline --prefix=$PREFIX --with-libraries=$PREFIX/lib --with-includes=$PREFIX/include
else
    ./configure --without-readline --prefix=$PREFIX --with-libraries=$PREFIX/lib --with-includes=$PREFIX/include --with-openssl
fi

make -j${CPU_COUNT}
make install
