#!/usr/bin/env bash
./configure --prefix="${PREFIX}" --with-rgbtxt="${PREFIX}/share/netpbm/rgb.txt"
make
make check
make install
