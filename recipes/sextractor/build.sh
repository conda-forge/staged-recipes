#!/bin/bash

sh autogen.sh
./configure --prefix=${PREFIX} \
    --enable-openblas \
    --with-openblas-incdir=${PREFIX}/include \
    --with-openblas-libdir=${PREFIX}/lib
make
make install
