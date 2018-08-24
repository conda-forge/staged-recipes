#!/bin/bash

./configure                                \
    --prefix="${PREFIX}"                   \
    --with-libunistring-prefix="${PREFIX}" \
    --with-libltdl-prefix="${PREFIX}"

make
make install
