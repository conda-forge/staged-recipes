#!/bin/bash
./configure --prefix=$PREFIX --enable-shared --disable-static &&
make
make check
make install