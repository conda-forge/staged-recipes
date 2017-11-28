#!/bin/bash

./configure \
    --with-sysroot=$PREFIX \
    --prefix=$PREFIX
make
make install

rm -rf $PREFIX/bin
mv $PREFIX/sbin $PREFIX/bin
