#!/bin/bash

./configure --prefix=$PREFIX \
    --enable-shared=yes \
    --enable-static=yes
make
make install
