#!/bin/bash

./configure --prefix=${PREFIX}        \
            --with-tcl=${PREFIX}/lib  \
            --with-tk=${PREFIX}/lib
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
