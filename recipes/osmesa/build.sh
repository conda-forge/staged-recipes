#!/usr/bin/env bash

find . -type f -name '*configure*'

configure --prefix=$PREFIX --enable-osmesa --disable-gallium --disable-egl --with-drivers=osmesa

make install
