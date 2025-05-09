#!/bin/bash

set -eu

cmake $SRC_DIR \
  -G Ninja \
  -B build \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_INSTALL_PREFIX=$SRC_DIR/pymeshlab \
  -DCMAKE_BUILD_TYPE=Release \
  -DMESHLAB_ALLOW_OPTIONAL_EXTERNAL_LIBRARIES=OFF \
  -DMESHLAB_BUILD_MINI=OFF

cmake --build build --parallel --target install

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
