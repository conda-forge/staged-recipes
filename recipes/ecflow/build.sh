#!/usr/bin/env bash

set -e # Abort on error.

export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

mkdir build && cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DENABLE_PYTHON=1 \
    -DENABLE_SSL=0 \
    -DBOOST_ROOT=$PREFIX

make -j $CPU_COUNT

make check

make install
