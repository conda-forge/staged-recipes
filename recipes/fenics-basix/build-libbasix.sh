#!/bin/bash
cd cpp
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -B build-dir \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DBLA_VENDOR="Generic" \
  -S .
cmake --build build-dir
cmake --install build-dir
