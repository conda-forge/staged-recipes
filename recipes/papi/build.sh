#!/bin/bash

set -ex

cd src
./configure \
    --prefix=$PREFIX \
    --with-static-lib=no \
    --with-shlib-tools \

make -j"${CPU_COUNT:-1}"
make install-lib install-utils install-hl-scripts install-pkgconf
