#!/bin/bash

chmod +x configure

./configure --prefix=$PREFIX --enable-cxx

make

if [ "$(uname)" != "Darwin" ];
then
    make check
fi

make install
