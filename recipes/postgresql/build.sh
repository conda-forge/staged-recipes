#!/bin/bash

if [ "$(uname)" == "Linux" ]; then
  OPTS="--with-openssl"
else
    # At first attempt, openssl-enabled fails to build on Mac.  Needs further investigation.
    OPTS=""
fi

./configure --prefix=$PREFIX \
            --without-readline \
            --with-libraries=$PREFIX/lib \
            --with-includes=$PREFIX/include \
            $OPTS

make
# make check # Failing with 'initdb: cannot be run as root'.
make install
