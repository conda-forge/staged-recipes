#!/usr/bin/env sh

./configure --prefix=$PREFIX --with-charset=utf8
make -j${CPU_COUNT}
make install
