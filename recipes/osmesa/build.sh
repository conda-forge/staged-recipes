#!/usr/bin/env bash

autoconf

./configure --prefix=$PREFIX --enable-osmesa --disable-gallium --disable-egl --disable-dri

make install
