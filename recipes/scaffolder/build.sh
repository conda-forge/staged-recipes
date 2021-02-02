#!/bin/bash
set -eu

### Create Makefiles
cmake -g Ninja \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_STANDARD=11 \
      -S . -B build

### Build
cmake --build build -- -j${CPU_COUNT}

### Install
cmake --install build --component scaffolder

### Test / Check ?
### There is no make check/test