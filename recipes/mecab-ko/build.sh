#!/usr/bin/env sh

./configure --prefix=$PREFIX --with-charset=utf8
make 
make install
