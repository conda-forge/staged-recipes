#!/bin/bash

./configure \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix=$PREFIX \
    --disable-echo \
    --enable-default-colors \
    --with-zlib \
    --with-bzlib \
    --enable-ipv6 \
    --disable-idna
#    --with-ssl=$PREFIX
make
make install




