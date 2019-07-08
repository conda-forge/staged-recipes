#!/bin/bash

./configure --prefix=${PREFIX} --enable-python-bindings=no

make -j${CPU_COUNT} ${VERBOSE_AT}
make install
