#!/bin/bash

set -e

mkdir build

cd build

cmake ../mariadb-connector-c-3.3.5 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR:STRING=lib \
    -DCMAKE_INSTALL_PREFIX:STRING=${PREFIX} \
    -DCMAKE_PREFIX_PATH:STRING=${PREFIX} \

make -j${CPU_COUNT}

make install
