#!/bin/bash

if [ ARCH = 32 ]; then
    TARGET="--target=i386"
fi

./configure $TARGET --prefix=$PREFIX
make
make install

rm -rf $PREFIX/doc
