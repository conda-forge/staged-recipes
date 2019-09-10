#!/bin/bash

./configure --prefix=${PREFIX} \
            --x-libraries=${PREFIX}/lib \
            --x-includes=${PREFIX}/include \
            --with-nc-config=${PREFIX}/bin/nc-config \
            --with-udunits2_incdir=${PREFIX}/include \
            --with-udunits2_libdir=${PREFIX}/lib \
            --with-png_incdir=${PREFIX}/include \
            --with-png_libdir=${PREFIX}/lib

make
make check
make install
