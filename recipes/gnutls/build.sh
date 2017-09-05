#!/bin/bash
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig/
CFLAGS="-m64" CXXFLAGS="-m64" NETTLE_LIBS=-lnettle NETTLE_CFLAGS=-I${PREFIX}/include/ HOGWEED_LIBS=-lhogweed ./configure --prefix="${PREFIX}" --without-libidn2 --with-included-libtasn1 --with-included-unistring --without-p11-kit 
make
make install
make check
