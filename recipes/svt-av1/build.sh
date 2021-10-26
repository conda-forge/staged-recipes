#!/bin/bash

set -ex

cd Build

cmake ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      ..


make -j${CPU_COUNT}

make install
