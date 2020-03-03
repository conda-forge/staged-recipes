#!/usr/bin/env bash
set -ex

if [[ "$(uname)" == 'Darwin' ]]; then
  export CXXFLAGS="$CXXFLAGS -std=c++17"
fi

./configure --prefix=${PREFIX}
make -j ${CPU_COUNT}
make check
make install
