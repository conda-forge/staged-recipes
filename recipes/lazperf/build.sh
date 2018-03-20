#!/bin/bash

set -ex

cmake -G "Unix Makefiles" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DWITH_TESTS=OFF

make -j $CPU_COUNT
make install
make test
