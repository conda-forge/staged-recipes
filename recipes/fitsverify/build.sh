#!/bin/bash

export PKG_CONFIG_PATH="$BUILD_PREFIX"/lib/pkgconfig
CFLAGS="-O3 -DSTANDALONE $(pkg-config --cflags cfitsio)"
LDFLAGS="$(pkg-config --libs cfitsio)"
OBJS=(
    ftverify.c
    fvrf_data.c
    fvrf_file.c
    fvrf_head.c
    fvrf_key.c
    fvrf_misc.c
)

set -x

${CC} ${CFLAGS} ${LDFLAGS} \
    -o fitsverify \
    ${OBJS[@]}

install -m 755 fitsverify $PREFIX/bin
