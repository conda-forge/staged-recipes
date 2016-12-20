#!/bin/bash

set -e
set -x

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DBUILD_SHARED_LIBS=on .

make -j${CPU_COUNT}
make install
