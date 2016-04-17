#!/bin/bash

export DYLD_LIBRARY_PATH=$PREFIX/lib

./configure \
    --prefix="${PREFIX}" \
    --disable-ldap \
    --with-ssl="${PREFIX}" \
    --with-zlib="${PREFIX}"
make
make test
make install

# Includes man pages and other miscellaneous.
rm -rf "${PREFIX}/share"
