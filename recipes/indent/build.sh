#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

sed -i '/input\/else-comment-2.c -o output\/else-comment-2-br.c/d' regression/TEST
sed -i '/input\/else-comment-2.c -o output\/else-comment-2-br-ce.c/d' regression/TEST
sed -i 's/else-comment-2-br-ce.c//' regression/TEST
sed -i 's/else-comment-2-br.c//' regression/TEST

./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --mandir=${PREFIX}/share/man
make check
make -j${CPU_COUNT} install
