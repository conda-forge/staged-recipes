#!/bin/bash

# This is part of 0003-Rename_CLI_tool.patch, but since `patch` on macOS
# does not automatically rename files we do so ourselves.
mv man/sex.1.in man/source-extractor.1.in || true
mv man/sex.x man/source-extractor.x || true

sh autogen.sh
./configure --prefix=${PREFIX} \
    --enable-openblas \
    --with-openblas-incdir=${PREFIX}/include \
    --with-openblas-libdir=${PREFIX}/lib
make
make check
make install
