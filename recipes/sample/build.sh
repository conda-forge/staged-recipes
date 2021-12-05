#!/bin/bash

set -x

./configure \
--prefix=${PREFIX} \
--enable-gold=yes \
--enable-plugins

make
make install
