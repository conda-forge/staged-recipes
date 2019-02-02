#!/bin/bash

set -ex

"${CC}" \
    -L"$PREFIX/lib" \
    -I"$PREFIX/include" \
    -lippi -lipps -lippcore \
    "$RECIPE_DIR/test_ipp.c" \
    -o test_ipp
./test_ipp
