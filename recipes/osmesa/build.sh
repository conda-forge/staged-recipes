#!/usr/bin/env bash

./configure --prefix=$PREFIX --enable-osmesa --disable-gallium --disable-egl --with-drivers=osmesa

make install
