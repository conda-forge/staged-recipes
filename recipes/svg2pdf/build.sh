#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/$(svg2pdf_LDFLAGS) $(svg2pdf_OBJECTS)/$(svg2pdf_OBJECTS) $(svg2pdf_LDFLAGS)/' src/Makefile.in
./configure --disable-silent \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --mandir=${PREFIX}/share/man
make -j${CPU_COUNT} install
