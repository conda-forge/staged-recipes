#!/bin/bash

set -e # Abort on error

mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX ..
cmake --build . --target install