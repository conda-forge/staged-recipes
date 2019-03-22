#!/usr/bin/env bash
set -eu

./configure \
    --prefix="${PREFIX}" \
    --with-openssl="${PREFIX}/" \
    --with-zlib="${PREFIX}/" \
    --enable-ipv6

# Using multiple cores fails so explicitly use -j1
make -j1
# make -j${CPU_COUNT}
make install
