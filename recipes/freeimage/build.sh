#!/bin/bash

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

cd ${SRC_DIR} || exit 1;

LANG="C" sed -i.bak 's:-o root -g root::' Makefile* || exit 1;

make || exit 1;

mkdir -p ${PREFIX}/lib || exit 1;
mkdir -p ${PREFIX}/include || exit 1;

make install PREFIX="${PREFIX}" DESTDIR="${PREFIX}" INCDIR="${PREFIX}/include" INSTALLDIR="${PREFIX}/lib" || exit 1;
