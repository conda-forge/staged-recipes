#!/bin/bash

if [[ ${target_platform} == linux-ppc64le ]]; then
  cmake -GNinja                        \
        -DCMAKE_BUILD_TYPE=Release     \
        -DCMAKE_INSTALL_PREFIX=$PREFIX \
        -DCMAKE_INSTALL_LIBDIR=lib     \
        $SRC_DIR
else
  cmake -GNinja                        \
        -DCMAKE_BUILD_TYPE=Release     \
        -DCMAKE_INSTALL_PREFIX=$PREFIX \
        -DCMAKE_INSTALL_LIBDIR=lib     \
        $SRC_DIR
fi

ninja
ninja install
