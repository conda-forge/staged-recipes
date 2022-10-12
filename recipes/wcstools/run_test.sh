#!/usr/bin/env bash
set -x -e -o pipefail

$CC -I$PREFIX/include -L$PREFIX/lib -Wl,-rpath=$PREFIX/lib -lwcs $RECIPE_DIR/dummy.c
if ! ./a.out; then
    echo test failed
else
    echo test success
fi
