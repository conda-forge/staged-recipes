#! /usr/bin/env bash

autoreconf -fis
./configure \
    --prefix="${PREFIX}" \
    --disable-systemd \
    --disable-static \
    --enable-shared
make -j"${CPU_COUNT}"
make install
