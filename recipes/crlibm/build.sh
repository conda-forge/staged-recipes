#!/usr/bin/env bash

cd src
./prepare
./configure --prefix=$PREFIX --enable-sse2
make
make check
make install
