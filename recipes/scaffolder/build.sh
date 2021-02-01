#!/bin/bash
set -eu

### Create Makefiles
cmake -g Ninja \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_STANDARD=11 \
      -S Project/CMake \
      -B build

### Build
cmake --build build -- -j${CPU_COUNT}

### Install
cmake --build build -- install

### Test / Check ?
### There is no make check/test