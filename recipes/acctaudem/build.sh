#!/bin/bash

set -ex

cd src && mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make -j $CPU_COUNT
make install
