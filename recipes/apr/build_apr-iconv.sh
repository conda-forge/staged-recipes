#!/bin/bash

cd apr-iconv
./configure \
        --prefix="${PREFIX}" \
        --enable-shared \
        --enable-static \
        --with-pic \
        --with-apr="${PREFIX}" \

make
make install
