#!/bin/bash
set -euo pipefail
export CFLAGS="-I${PREFIX}/include ${CFLAGS}"
./autogen.sh
./configure --prefix=$PREFIX
make
make install
