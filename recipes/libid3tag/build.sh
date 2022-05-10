#!/bin/bash

set -eux -o pipefail

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -S . -B build
cmake --build build
cmake --install build
