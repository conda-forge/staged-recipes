#!/bin/bash
set -ex

pushd . && mkdir build && cd build

cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DCMAKE_BUILD_TYPE=Release ..
make -j$CPU_COUNT
make test
make install

popd && rm -rf build
