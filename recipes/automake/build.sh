#!/bin/sh

./configure --prefix=$PREFIX
make
# make check TODO: There is one failure I need to check.
make install
