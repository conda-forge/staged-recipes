#!/bin/bash

LDFLAGS="-rpath $PREFIX/lib $LDFLAGS"

./configure \
    --prefix=$PREFIX \
    --with-readline \
    --with-libraries=$PREFIX/lib \
    --with-includes=$PREFIX/include \
    --with-openssl \
    --without-python \
    --with-uuid=e2fs \
    --with-libxml \
    --with-libxslt \
    --with-gssapi

make -j $CPU_COUNT
make -j $CPU_COUNT -C contrib

make check
make check -C contrib
make check -C src/pl

make install
make install -C contrib
