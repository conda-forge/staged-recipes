#!/bin/bash

set -eux -o pipefail

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="${CONDA_PREFIX}" ..
cmake --build . --target install
