#! /bin/sh

./configure --prefix=${PREFIX} --disable-static
make
make check
make install
