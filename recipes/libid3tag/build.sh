#!/bin/bash

set -eux -o pipefail

export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -S . -B build
cmake --build build
cmake --install build
