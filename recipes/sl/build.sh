#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make CC="${CC} ${CFLAGS} ${LDFLAGS}" -e
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man/man1
install -m 755 sl ${PREFIX}/bin
install -m 644 sl.1 ${PREFIX}/share/man/man1
