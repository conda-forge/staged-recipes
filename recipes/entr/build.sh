#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export MANPREFIX=${PREFIX}/share/man
./configure
make -j${CPU_COUNT}
TERM=xterm make test
make install
