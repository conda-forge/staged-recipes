#!/bin/bash

./autogen.sh
./configure --prefix=$PREFIX --enable-watch8bit

make
make check
make install
