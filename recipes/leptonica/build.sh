#!/usr/bin/env bash

mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
cmake -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_BUILD_TYPE=Release
make install
