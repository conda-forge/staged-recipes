#!/usr/bin/env bash

mkdir ../build
cd ../build
cmake $SRC_DIR \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DWITH_TESTS=YES
make
make install
