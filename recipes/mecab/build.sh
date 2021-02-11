#!/usr/bin/env sh

cd mecab
./configure --prefix=$PREFIX --with-charset=utf8
make -j${CPU_COUNT}
make check
make install
