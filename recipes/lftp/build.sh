#!/bin/bash

set -e

configure_args=(
    --prefix=$PREFIX
    --with-sysroot=$PREFIX
    --disable-dependency-tracking
    --disable-silent-rules
    --without-gnutls
    --with-openssl
    --with-readline=$PREFIX

    --without-libresolv
    --without-libidn
)

export LDFLAGS="$LDFLAGS -Wl,-rpath -Wl,$PREFIX/lib -L$PREFIX/lib"
export CFLAGS="$CFLAGS -I$PREFIX/include"
export CXXFLAGS="$CXXFLAGS -O2 -g"

./configure "${configure_args[@]}"

make -j$CPU_COUNT
make install
make check
