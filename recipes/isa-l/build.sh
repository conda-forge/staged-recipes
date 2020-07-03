#!/bin/bash

unset AS  # This makes sure nasm is set as assembler by configure and not GCC.
unset CFLAGS  # default CFLAGS are incompatible with nasm. Set by configure.
./autogen.sh
./configure --prefix=${PREFIX}

make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

# Remove man pages
rm -rf ${PREFIX}/share