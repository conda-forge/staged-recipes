#!/bin/bash

set -e

# we will install the libs here so we can find them later
# copying files out of the build without using make install-strip
# is not a great idea. by using this weird prefix, we can install to a single
# place and then build the library and compiler package separately by
# copying files from here
mkdir -p ${SRC_DIR}/install_prefix_conda

mkdir -p ${SRC_DIR}/build_conda
cd ${SRC_DIR}/build_conda

../configure \
    --prefix=${SRC_DIR}/install_prefix_conda \
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
