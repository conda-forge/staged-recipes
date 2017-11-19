#!/bin/bash

./configure --prefix=$PREFIX \
--with-zlib=$PREFIX \
--with-jpeg=$PREFIX \
--with-libtiff=$PREFIX \
--with-proj=$PREFIX 

make
make install

