#! /usr/bin/env bash

autoreconf -fis
./configure \
    --prefix="${PREFIX}" \
    --disable-systemd \
    --disable-static \
    --enable-shared
make
make install
