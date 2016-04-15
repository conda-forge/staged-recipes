#!/bin/bash

./configure --shared --prefix=$PREFIX
make
make install

rm -rf $PREFIX/share
