#!/usr/bin/env bash

./configure --prefix="${PREFIX}" \
    --with-boost="${PREFIX}/lib" \
    --disable-dependency-tracking

make
make install

exit 0
