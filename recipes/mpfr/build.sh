#!/bin/bash

./configure --prefix=$PREFIX \
            --with-gmp=$PREFIX \
            --enable-static

make
make check
make install
