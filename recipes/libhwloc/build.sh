#!/bin/bash

set -e

chmod +x configure

DISABLES="--disable-cairo --disable-libxml2 --disable-opencl --disable-cuda --disable-nvml"
DISABLES="$DISABLES --disable-gl --disable-libnuma --disable-libudev"

if [ `uname` == Darwin ]; then
    ./configure --prefix=$PREFIX --disable-shared $DISABLES
else
    ./configure --prefix=$PREFIX $DISABLES
fi

make
make check
make install
