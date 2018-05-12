#!/bin/bash
./configure --prefix=$PREFIX --enable-shared --disable-static &&
make
cp src/.libs/libsigsegv.so $PREFIX/lib
