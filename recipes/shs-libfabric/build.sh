#!/bin/bash
set -ex

./autogen.sh

./configure \
    --prefix=$PREFIX \
    --enable-cxi \
    --with-libnl=$PREFIX  \
    --disable-static \
    --disable-psm3 \
    --disable-opx \
    --disable-verbs \
    --disable-efa 

make -j${CPU_COUNT}

make install
