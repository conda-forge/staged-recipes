#!/bin/bash
./configure --prefix="${PREFIX}" --without-libidn2 --with-included-libtasn1 --with-included-unistring --without-p11-kit --without-libcrypto
make
make install
make check
