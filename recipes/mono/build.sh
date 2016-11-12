#!/usr/bin/env bash

./configure --prefix=$PREFIX --with-glib=embedded --enable-nls=no

make
make install
