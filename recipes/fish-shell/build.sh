#!/bin/sh

autoconf
./configure --prefix=$PREFIX
make -j4
make install
