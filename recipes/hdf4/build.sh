#!/bin/bash


export CFLAGS="${CFLAGS} -pipe -O2 -fPIC -I${PREFIX}/include"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"

chmod +x configure

./configure \
--disable-static \
--enable-linux-lfs \
--with-ssl \
--with-zlib \
--with-jpeg \
--disable-netcdf \
--disable-fortran \
--prefix=${PREFIX}

make
make install
rm -rf ${PREFIX}/share/hdf4_examples;

