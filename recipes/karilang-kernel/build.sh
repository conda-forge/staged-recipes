#!/bin/bash

echo "Building ..."
echo $PREFIX
echo $SRC_DIR

ls -la
pwd


cmake -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX    \
      -DCMAKE_INSTALL_LIBDIR=lib     \
      $SRC_DIR/karilang-kernel

make install
