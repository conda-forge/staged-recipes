#!/bin/bash

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
export DYLD_LIBRARY_PATH="${PREFIX}/lib"
export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"

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
