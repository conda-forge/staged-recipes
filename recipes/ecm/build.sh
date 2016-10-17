#!/usr/bin/env bash

chmod +x configure

./configure --prefix=$PREFIX --with-gmp=$PREFIX --enable-shared
make
make check
make install
