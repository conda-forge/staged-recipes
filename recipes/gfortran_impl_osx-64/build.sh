#!/bin/bash

set -e

mkdir -p build_conda
cd build_conda

../configure \
    --prefix=${PREFIX} \
    --with-libiconv-prefix=${PREFIX} \
    --enable-languages=c,fortran \
    --with-tune=generic \
    --disable-multilib \
    --enable-checking=release \
    --disable-bootstrap \
    --build=${macos_machine} \
    --with-gmp=${PREFIX} \
    --with-mpfr=${PREFIX} \
    --with-mpc=${PREFIX} \
    --with-isl=${PREFIX}

# using || to quiet logs unless there is an issue
{
    make -j"${CPU_COUNT}" >& make_logs.txt
} || {
    tail -n 5000 make_logs.txt
    exit 1
}

# using || to quiet logs unless there is an issue
{
    make install-strip >& make_install_logs.txt
} || {
    tail -n 5000 make_install_logs.txt
    exit 1
}
