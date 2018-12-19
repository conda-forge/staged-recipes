#!/bin/bash

set -o pipefail

./configure --prefix="${PREFIX}" \
    --enable-shared \
    --disable-static \
    --disable-gtk-doc \
    --disable-gtk-doc-html \
    --disable-gtk-doc-pdf \
    --disable-nls \
    --disable-code-coverage \
    --without-libiconv-prefix \
    --without-libintl-prefix \
    --without-gcov \
    2>&1 | tee configure.log

make
make check
make install

# Save some space
rm -rf "${PREFIX}/share/info"
rm -rf "${PREFIX}/share/man"
rm -rf "${PREFIX}/share/gtk-doc"
