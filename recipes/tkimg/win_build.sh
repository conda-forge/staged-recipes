#!/bin/bash

export PATH=$PATH:/mingw64/bin/

env
pwd
ls -al

ARCH_FLAG=""
if [[ ${ARCH} == 64 ]]; then
    ARCH_FLAG="--enable-64bit"
fi

./configure --prefix=${PREFIX}        \
            --with-tcl=${PREFIX}/lib  \
            --with-tk=${PREFIX}/lib   \
			${ARCH_FLAG}
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
