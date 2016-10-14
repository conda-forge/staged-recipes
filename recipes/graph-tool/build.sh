#!/usr/bin/env bash

./configure \
    --prefix="${PREFIX}" \
    --with-boost="${PREFIX}/lib"
make
make install
exit 0
