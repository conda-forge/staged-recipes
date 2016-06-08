#!/bin/bash

cd src

autoreconf -i

./configure --prefix=$PREFIX

make
make check
make install
