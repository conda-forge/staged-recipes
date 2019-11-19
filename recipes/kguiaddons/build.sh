#!/usr/bin/env bash
set -ex

mkdir build
pushd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release     \
      -Wno-dev \
      ..

make -j ${CPU_COUNT}
# Test fail on CI with Child aborted***Exception, but pass locally
# make test
make install
popd
