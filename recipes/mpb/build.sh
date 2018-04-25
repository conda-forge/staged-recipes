#!/bin/bash

./configure --prefix="${PREFIX}" --enable-shared --with-libctl=no --with-hermitian-eps

make
make check
make install

rm ${PREFIX}/lib/libmpb.a
