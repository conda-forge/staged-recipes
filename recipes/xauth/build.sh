#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --disable-debug \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --enable-unix-transport \
    --enable-tcp-transport \
    --enable-ipv6 \
    --enable-local-transport \
    --sysconfdir=${PREFIX}/etc \
    --localstatedir=${PREFIX}/var \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib

make
make check
make install
