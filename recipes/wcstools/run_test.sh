#!/usr/bin/env bash
set -x -e -o pipefail

rdelim="="
if [[ $target_platform == osx-* ]]; then
    rdelim=","
fi
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
wcstools_flags=$(pkg-config --cflags --libs wcstools)

$CC $wcstools_flags -Wl,-rpath${rdelim}$PREFIX/lib $RECIPE_DIR/dummy.c
if ! ./a.out; then
    echo test failed
else
    echo test success
fi
