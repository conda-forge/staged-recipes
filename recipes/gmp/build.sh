#!/bin/bash

chmod +x configure

./configure --prefix=$PREFIX --enable-cxx

make
make check
make install
