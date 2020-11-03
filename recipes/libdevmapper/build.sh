#! /bin/sh

autoreconf -fi
./configure \
  --prefix="${PREFIX}" \
  --enable-pkgconfig
make libdm.install
