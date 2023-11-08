#!/bin/bash

set -eux -o pipefail

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" ..
cmake --build . --target install
