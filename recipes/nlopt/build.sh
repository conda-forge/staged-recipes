#!/bin/sh

./configure          \
  --prefix=${PREFIX} \
  --enable-shared    \
  --without-octave   \
  --without-matlab   \
  --without-guile

make
make install
