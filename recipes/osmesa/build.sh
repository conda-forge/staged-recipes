#!/usr/bin/env bash

aclocal
autoconf

./configure --prefix=$PREFIX --enable-osmesa --disable-gallium --disable-egl --disable-dri

make install
