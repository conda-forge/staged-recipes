#!/bin/bash

set -xe

export PATH=$PATH:/mingw64/bin/

ARCH_FLAG=""
if [[ ${ARCH} == 64 ]]; then
    ARCH_FLAG="--enable-64bit"
fi

./configure --prefix=${CYGWIN_PREFIX}        \
            --with-tcl=${CYGWIN_PREFIX}/lib  \
            --with-tk=${CYGWIN_PREFIX}/lib   \
			${ARCH_FLAG}
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
