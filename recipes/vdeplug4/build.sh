#!/bin/bash

set -ex


mkdir build
cd build

cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_MANDIR=man ..
cmake --build . -j "$CPU_COUNT"
cmake --build . --target install

