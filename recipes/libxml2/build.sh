#!/bin/bash

export CPPFLAGS="-I${PREFIX}/include"

if [ $(uname) == Darwin ]; then
  export OPTS="--without-lzma"
else
  export OPTS="--with-lzma=$PREFIX"
fi

./autogen.sh

./configure --prefix=$PREFIX \
            --with-zlib=$PREFIX \
            --with-python=$PREFIX \
            $OPTS

make
if [ $(uname) != Darwin ]; then
  make check
fi
make install
