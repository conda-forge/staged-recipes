#!/bin/bash

mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -G Ninja \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ..
ninja install -j${CPU_COUNT}
