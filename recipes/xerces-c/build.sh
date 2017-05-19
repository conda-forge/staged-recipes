#!/bin/bash

./configure --prefix=$PREFIX \
    --disable-network 

make
make check
make install

