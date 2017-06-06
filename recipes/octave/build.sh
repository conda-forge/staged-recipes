#!/usr/bin/env bash

export CFLAGS="-I${PREFIX}/include ${CFLAGS}"
export CXXFLAGS="-I${PREFIX}/include ${CXXFLAGS}"
export LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib ${LDFLAGS}"

chmod +x configure
chmod +x build-aux/mk-opts.pl

./configure --help
./configure --prefix=$PREFIX \
    --disable-docs \
    --enable-readline \
    --enable-shared \
    --enable-dl \
    --without-qhull \
    --without-qrupdate \
    --with-qt=4 \
    --without-magick \
    --without-opengl \
    --without-framework-opengl \
    --without-framework-carbon \
    --with-hdf5-includedir=${PREFIX}/include \
    --with-hdf5-libdir=${PREFIX}/lib

make -j${CPU_COUNT}
make install

