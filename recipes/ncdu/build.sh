#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

./configure --prefix="${PREFIX}"
make -j${CPU_COUNT}
make install
