#!/usr/bin/env bash
# Enable bash strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

./configure \
    --prefix=${PREFIX}

make ${CPU_COUNT}
make check
make install
