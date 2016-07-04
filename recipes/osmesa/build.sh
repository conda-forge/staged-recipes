#!/usr/bin/env bash

ls
cd "mesa-mesa-${PKG_VERSION}"

./configure --prefix=$PREFIX --enable-osmesa --disable-gallium --disable-egl --with-drivers=osmesa

make install
