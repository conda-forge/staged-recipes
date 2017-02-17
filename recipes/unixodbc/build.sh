#!/bin/bash

set -e
set -x

CFLAGS="-O2 ${CFLAGS}" CXXFLAGS="-O2 ${CXXFLAGS}" ./configure --prefix=$PREFIX
make -j${CPU_COUNT}
make install
