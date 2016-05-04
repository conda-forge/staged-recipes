#!/bin/bash

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

if [[ `uname` == "Darwin" ]]
then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
    export CC=clang
    export CXX=clang++
fi

./configure \
    --disable-ldap \
    --prefix=${PREFIX} \
    --with-ca-bundle=${PREFIX}/ssl/cacert.pem \
    --with-ssl=${PREFIX} \
    --with-zlib=${PREFIX} \
|| cat config.log

make
make test
make install

# Includes man pages and other miscellaneous.
rm -rf "${PREFIX}/share"
