#!/bin/bash

set -exuo pipefail

mkdir -p $PREFIX/lib
cp build/dist/lib/libduckdb${SHLIB_EXT} $PREFIX/lib
