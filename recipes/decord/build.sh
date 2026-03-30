#!/usr/bin/env bash
set -euxo pipefail

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DFFMPEG_DIR="$PREFIX" \
  -DUSE_CUDA=OFF \
  ..

make -j"${CPU_COUNT}"

cd ../python
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
