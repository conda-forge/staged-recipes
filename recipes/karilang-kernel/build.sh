#!/bin/bash

echo "Building ..."
echo "$PREFIX"
echo "$SRC_DIR"

ls -la
ls -la karilang-kernel
ls -la karilang-kernel/src
ls -la karilang-kernel/src/KariLang
ls -la karilang-kernel/src/KariLang/src
pwd


cmake -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX    \
      -DCMAKE_INSTALL_LIBDIR=lib     \
      $SRC_DIR/karilang-kernel

make install
