#!/usr/bin/env bash
set -ex

export CFLAGS="${CFLAGS} -DXATTR_NAME_CAPS"

make CC=$CC \
     prefix=$PREFIX \
     CFLAGS="${CFLAGS}" \
     LDFLAGS="${LDFLAGS}" \
     lib=lib
make prefix=$PREFIX \
     lib=lib \
     SBINDIR=$PREFIX/sbin \
     PAM_LIBDIR=$PREFIX/lib \
     RAISE_SETFCAP=no \
     install
