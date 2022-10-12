#!/usr/bin/env bash
set -x -e -o pipefail

rdelim="="
if [[ $target_platform == osx-* ]]; then
    rdelim=","
fi

$CC -I$PREFIX/include -L$PREFIX/lib -Wl,-rpath${rdelim}$PREFIX/lib -lwcs $RECIPE_DIR/dummy.c
if ! ./a.out; then
    echo test failed
else
    echo test success
fi
