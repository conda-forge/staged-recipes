#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --mandir=${PREFIX}/share/man

mkdir -p ${PREFIX}/share/man/man1
make all mandir=${PREFIX}/share/man/man1 CP=cp CPFLAGS="-r"
make check mandir=${PREFIX}/share/man/man1 CP=cp CPFLAGS="-r"
make install mandir=${PREFIX}/share/man/man1 CP=cp CPFLAGS="-r"
