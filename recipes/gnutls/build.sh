#!/bin/bash
./configure --prefix="${PREFIX}" --with-included-libtasn1 --with-included-unistring --without-p11-kit 
make
make install
make check
