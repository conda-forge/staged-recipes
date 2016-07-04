#!/usr/bin/env bash

aclocal || exit 1
autoconf || exit 1

./configure --prefix=$PREFIX --enable-osmesa --disable-gallium --disable-egl --disable-dri

make install
