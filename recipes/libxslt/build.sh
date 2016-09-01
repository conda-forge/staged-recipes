#!/bin/bash

./configure --prefix=$PREFIX \
            --with-libxml-prefix=$PREFIX

make
make check
make install
