#!/bin/bash

# Fix shebangs
for f in test/compare_sam.pl; do
    sed -i.bak -e 's|^#!/usr/bin/perl -w|#!/usr/bin/env perl|' "$f"
    rm -f "$f.bak"
done

./configure \
    --prefix="${PREFIX}" \
    --host="${HOST}" \
    --enable-libcurl \
    --enable-plugins \
    --enable-s3 \
    --enable-gcs \
    CFLAGS="$CFLAGS -I${PREFIX}/include" \
    LDFLAGS="$LDFLAGS -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"

make -j${CPU_COUNT} ${VERBOSE_AT}

make test

make install prefix=$PREFIX
