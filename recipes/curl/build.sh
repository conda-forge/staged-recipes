#!/bin/bash

export DYLD_LIBRARY_PATH=$PREFIX/lib

./configure \
    --disable-ldap \
    --with-ssl=$PREFIX \
    --with-zlib=$PREFIX \
    --prefix=$PREFIX

make
make install
