#!/bin/bash

# By patching nasm-filter.sh to include the absolute path to $BUILD_PREFIX/bin/nasm
# we have guaranteed that the correct nasm is used.
# Variable AS needs to be set to nasm in order for the configure script to succeed.
export AS=nasm

./autogen.sh
./configure --prefix=${PREFIX}

make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

# Remove man pages
rm -rf ${PREFIX}/share
