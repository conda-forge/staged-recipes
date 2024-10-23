#!/bin/bash

ln -sf $(which $CC) $BUILD_PREFIX/bin/gcc
export CFLAGS="$CFLAGS ${LDFLAGS/-Wl,--gc-sections/}"

./scripts/onload_build --user

./scripts/onload_install \
  --nokernelfiles \
  --nobuild \
  --usrdir=$PREFIX \
  --sbindir=$PREFIX/sbin \
  --sysconfdir=$PREFIX/etc \
  --lib64dir=$PREFIX/lib

# delete python package for now
rm -rf $PREFIX/lib/python3*
