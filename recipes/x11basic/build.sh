#!/bin/bash
set -ex

cd src
./configure --prefix="${PREFIX}" \
    --without-framebuffer \
    --with-x \
    --includedir="${PREFIX}/include"
make install
make check
