#!/usr/bin/env bash
set -euxo pipefail

mkdir -p build
cd build

if [[ ! -z "${cuda_compiler_version+x}" && "${cuda_compiler_version}" != "None" ]]; then
  EXTRA_CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=all -DUSE_CUDA=ON"
else
  EXTRA_CMAKE_ARGS="-DUSE_CUDA=OFF"
fi

cmake ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DFFMPEG_DIR="$PREFIX" \
  ${EXTRA_CMAKE_ARGS} \
  ..

make -j"${CPU_COUNT}"

cd ../python
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
