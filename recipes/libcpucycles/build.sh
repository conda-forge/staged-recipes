#!/bin/bash

set -ex

echo "$CC $CFLAGS" >> compilers/default

./configure --prefix=$PREFIX

make

make install

rm $PREFIX/lib/*.a
