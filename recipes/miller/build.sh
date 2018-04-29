#!/bin/bash

chmod +x configure

./configure --disable-multilib  --prefix=$PREFIX

make
make check
make install