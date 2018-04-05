#!/bin/bash

set -ex

export CXXFLAGS="$CXXFLAGS -std=c++11"

cmake -G "Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release

make -j $CPU_COUNT
make install
