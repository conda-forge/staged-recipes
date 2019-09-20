#!/usr/bin/env bash
set -ex

export CFLAGS="-I${PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr/include ${CFLAGS}"

make CC=$CC \
     prefix=$PREFIX \
     CFLAGS="${CFLAGS}" \
     lib=lib
make prefix=$PREFIX \
     lib=lib \
     SBINDIR=$PREFIX/sbin \
     PAM_LIBDIR=$PREFIX/lib \
     RAISE_SETFCAP=no \
     install
