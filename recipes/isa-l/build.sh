#!/bin/bash

# Use nasm as default assembler. Use relative path here as configure script
# seems to choke on absolute paths using $CONDA_PREFIX.
export AS=nasm
export CFLAGS=""  # default CFLAGS are incompatible with nasm.
./autogen.sh
./configure --prefix=${PREFIX}

make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

# Remove man pages
rm -rf ${PREFIX}/share
