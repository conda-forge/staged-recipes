#!/bin/bash

./configure \
        --prefix="${PREFIX}" \
        --enable-shared \
        --enable-static \
        --with-pic \
        --with-apr="${PREFIX}" \

make
make install
