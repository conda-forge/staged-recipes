#!/bin/bash

set -ex

mkdir build && cd build

cmake \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
     ..
cmake --build . --config Release
cmake --build . --config Release --target test
cmake --build . --config Release --target install
