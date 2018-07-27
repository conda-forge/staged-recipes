#!/bin/bash

sh build.sh

./configure --prefix=$PREFIX \
            --with-curl=$PREFIX \
            --with-libxml=$PREFIX \
            --with-pcre=$PREFIX \
            --with-geoip=$PREFIX \
            --with-yajl=$PREFIX

make

make install