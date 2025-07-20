#!/usr/bin/env bash
set -exuo pipefail

make PREFIX="$PREFIX" OPT_CFLAGS="-DACPI_PACKED_POINTERS_NOT_SUPPORTED"
make install PREFIX="$PREFIX"
