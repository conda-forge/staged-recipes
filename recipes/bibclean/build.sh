#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./configure --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --mandir=${PREFIX}/share/man

mkdir -p ${PREFIX}/share/man/man1
make -j${CPU_COUNT} all mandir=${PREFIX}/share/man/man1 CP=cp CPFLAGS="-r"
make -j${CPU_COUNT} check mandir=${PREFIX}/share/man/man1 CP=cp CPFLAGS="-r"
make -j${CPU_COUNT} install mandir=${PREFIX}/share/man/man1 CP=cp CPFLAGS="-r"
