#!/usr/bin/env bash

cd src
./prepare
./configure --prefix=$PREFIX
make
make check
make install
rm $PREFIX/lib/libcrlibm.a
rm $PREFIX/include/crlibm.h
