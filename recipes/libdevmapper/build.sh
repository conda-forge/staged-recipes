#! /bin/sh

autoreconf -fi
./configure \
  --prefix="${PREFIX}" \
  --enable-pkgconfig
make -j"${CPU_COUNT}" libdm.install
