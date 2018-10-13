#!/bin/bash

# get stuff we need
./contrib/download_prerequisites

mkdir -p ${SRC_DIR}/build_conda
cd ${SRC_DIR}/build_conda

../configure \
    --build=x86_64-apple-darwin \
    --prefix=${PREFIX} \
    --enable-languages="c,fortran" \
    --disable-build-poststage1-with-cxx \
    --disable-libstdcxx-pch \
    --enable-checking=release \
    --disable-multilib \
    --without-stabs \
    --without-gnu-as \
    --disable-bootstrap \
    --with-dwarf2
make
# make install
