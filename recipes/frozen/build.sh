#!/bin/bash

set -eux -o pipefail

mkdir build
cd build
cmake CMAKE_BUILD_TYPE=Release\
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" ..

make install
