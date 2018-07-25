#!/bin/bash

set -e
set -x

mkdir -p build && cd build
cmake -DBUILD_PYTHON_INTERFACE=ON -DCMAKE_INSTALL_PREFIX=$PREFIX ../
make -j $CPU_COUNT
make install

