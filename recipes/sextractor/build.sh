#!/bin/bash

mv man/sex.1.in man/s_extractor.1.in
mv man/sex.x man/s_extractor.x
sh autogen.sh
./configure --prefix=${PREFIX} \
    --enable-openblas \
    --with-openblas-incdir=${PREFIX}/include \
    --with-openblas-libdir=${PREFIX}/lib
make
make install
