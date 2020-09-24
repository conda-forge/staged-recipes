#!/bin/bash

set -ex

cd src && mkdir build && cd build
cmake ..
make -j $CPU_COUNT
make install