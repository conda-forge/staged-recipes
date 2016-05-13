#!/usr/bin/env bash

mkdir ../build
cd ../build
cmake --debug-output $SRC_DIR \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DWITH_TESTS=YES
make VERBOSE=1
make install
