#!/usr/bin/env bash

set -e

export PYTHON=

mkdir ../build && cd ../build

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      $SRC_DIR

make -j $CPU_COUNT

ctest --output-on-failure -j $CPU_COUNT -I test_list.txt
make install