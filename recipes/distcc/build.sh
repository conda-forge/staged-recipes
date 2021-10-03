#!/bin/bash

export CFLAGS="${CFLAGS:-} -Wno-error"

./autogen.sh
./configure \
    --prefix=${PREFIX} \
    --without-avahi \
    --without-libiberty

make clean
make -j${CPU_COUNT}
make install
