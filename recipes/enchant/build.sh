#!/bin/bash

autoreconf -vfi
./configure --prefix=$PREFIX \
  --disable-static \
  --enable-relocatable
make
make install
