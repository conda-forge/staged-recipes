#!/bin/bash


export CFLAGS="${CFLAGS} -pipe -O2 -fPIC -I${PREFIX}/include"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"

chmod +x configure

# The --enable-silent-rules is needed because Travis CI dies on the long output from this build
./configure \
    --disable-static \
    --enable-linux-lfs \
    --with-ssl \
    --with-zlib \
    --with-jpeg \
    --disable-netcdf \
    --disable-fortran \
    --enable-silent-rules \
    --prefix=${PREFIX}

make
make install
rm -rf ${PREFIX}/share/hdf4_examples;

