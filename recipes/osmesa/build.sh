#!/usr/bin/env bash

aclocal
autoconf

./configure --prefix=$PREFIX --enable-osmesa

make install
