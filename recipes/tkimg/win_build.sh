#!/bin/bash

set -xe

export PATH=$PATH:/mingw64/bin/

ARCH_FLAG=""
if [[ ${ARCH} == 64 ]]; then
    ARCH_FLAG="--enable-64bit"
fi

MSYS_PREFIX=${CYGWIN_PREFIX/\/cygdrive/}

ls -al $MSYS_PREFIX

./configure --prefix=${MSYS_PREFIX}        \
            --with-tcl=${MSYS_PREFIX}/lib  \
            --with-tk=${MSYS_PREFIX}/lib   \
			${ARCH_FLAG}
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
