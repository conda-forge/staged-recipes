#!/bin/bash

ARCH_FLAG=""
if [[ ${ARCH} == 64 ]]; then
    ARCH_FLAG="--enable-64bit"
fi

ls -al $PREFIX
ls -al $PREFIX/include
ls -al $BUILD_PREFIX/include

./configure --prefix=${PREFIX}        \
            --with-tcl=${PREFIX}/lib  \
            --with-tk=${PREFIX}/lib   \
			${ARCH_FLAG}
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
