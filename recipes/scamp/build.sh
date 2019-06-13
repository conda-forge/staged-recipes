#!/bin/bash

sh autogen.sh
./configure --prefix=${PREFIX} \
    --enable-openblas \
    --with-openblas-incdir=${PREFIX}/include \
    --with-openblas-libdir=${PREFIX}/lib \
    --with-curl-incdir=${PREFIX}/include \
    --with-curl-libdir=${PREFIX}/lib \
    --enable-plplot=no
make
make install
