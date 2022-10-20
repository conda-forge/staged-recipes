#!/usr/bin/env bash
set -x -e -o pipefail

export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
wcstools_flags=$(pkg-config --cflags --libs wcstools)

$CC $wcstools_flags $LDFLAGS $RECIPE_DIR/dummy.c
if ! ./a.out; then
    echo test failed
else
    echo test success
fi
