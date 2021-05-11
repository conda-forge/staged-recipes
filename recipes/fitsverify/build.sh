#!/bin/bash
CFLAGS="$CFLAGS -O3 -DSTANDALONE $(pkg-config --cflags cfitsio)"
LDFLAGS="$LDFLAGS $(pkg-config --libs cfitsio)"
${CC} ${CFLAGS} ${LDFLAGS} \
    -o fitsverify \
    ftverify.c \
    fvrf_data.c \
    fvrf_file.c \
    fvrf_head.c \
    fvrf_key.c \
    fvrf_misc.c
