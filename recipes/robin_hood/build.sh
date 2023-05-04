#!/bin/bash

cmake ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DRH_STANDALONE_PROJECT=OFF \
    $SRC_DIR

make install
