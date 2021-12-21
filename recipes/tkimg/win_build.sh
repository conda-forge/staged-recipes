#!/bin/bash

set -xe

export PATH=$PATH:/mingw64/bin/

ARCH_FLAG=""
if [[ ${ARCH} == 64 ]]; then
    ARCH_FLAG="--enable-64bit"
fi

MSYS_PREFIX=${CYGWIN_PREFIX/\/cygdrive/}

./configure --prefix=${MSYS_PREFIX}/Library        \
            --with-tcl=${MSYS_PREFIX}/Library/lib  \
            --with-tk=${MSYS_PREFIX}/Library/lib   \
			${ARCH_FLAG}
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
