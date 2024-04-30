#!/usr/bin/env bash

./configure \
    --prefix=$PREFIX \
    --disable-silent-rules \
    --with-libiconv-prefix=$PREFIX \
    --with-libintl-prefix=$PREFIX \
    --with-json=json-c \
    --with-xml2=libxml2 \
    --with-curses=ncurses \
    --with-db=db

make install
