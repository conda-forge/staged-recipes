#!/bin/bash

export LDFLAGS=${LDFLAGS}" -Wl,-headerpad_max_install_names -Wl,-L${PREFIX}/lib -Wl,-rpath ${PREFIX}/lib"

mkdir -p ${SRC_DIR}/build_conda
cd ${SRC_DIR}/build_conda

../configure \
    --enable-languages=c,fortran \
    --build=x86_64-apple-darwin \
    --prefix=${PREFIX} \
    --with-gmp="$PREFIX" \
    --with-mpfr="$PREFIX" \
    --with-mpc="$PREFIX" \
    --with-isl="$PREFIX" \
    --with-cloog="$PREFIX" \
    --with-libiconv-prefix="$PREFIX" \
    --disable-build-poststage1-with-cxx \
    --disable-libstdcxx-pch \
    --enable-checking=release \
    --disable-multilib \
    --with-boot-ldflags="$LDFLAGS" \
    --with-stage1-ldflags="$LDFLAGS" \
    --with-tune=generic \
    --without-stabs \
    --without-gnu-as \
    --disable-bootstrap \
    --with-dwarf2

# using || to quiet logs unless there is an issue
{
    make -j"${CPU_COUNT}" >& make_logs.txt
} || {
    tail -n 1000 make_logs.txt
    exit 1
}

{
    make install-strip >& make_install_logs.txt
} || {
    tail -n 1000 make_install_logs.txt
    exit 1
}
