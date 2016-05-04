#!/bin/bash

export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

./configure \
    --disable-ldap \
    --with-ca-bundle=$PREFIX/ssl/cacert.pem \
    --with-ssl=$PREFIX \
    --with-zlib=$PREFIX \
    --prefix=$PREFIX

make
make install
