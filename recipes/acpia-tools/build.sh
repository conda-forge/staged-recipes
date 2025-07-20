#!/usr/bin/env bash
set -exuo pipefail

if [ "x$PATH_OVERRIDE" != "x" ]; then
    PATH="$PATH_OVERRIDE:$PATH"
fi

make PREFIX="$PREFIX" OPT_CFLAGS="-DACPI_PACKED_POINTERS_NOT_SUPPORTED"
make install PREFIX="$PREFIX"
