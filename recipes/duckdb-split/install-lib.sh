#!/bin/bash

set -exuo pipefail

cp build/dist/lib/libduckdb${SHLIB_EXT} $PREFIX/lib
