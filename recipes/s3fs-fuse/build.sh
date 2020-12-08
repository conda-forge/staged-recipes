#!/usr/bin/env bash
./autogen.sh

./configure \
  --prefix=${PREFIX} \
  --sbindir=${PREFIX}/bin \
  --with-openssl

make

make install
