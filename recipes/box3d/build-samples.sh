#!/usr/bin/env bash
set -euxo pipefail

rm -rf build-samples

cmake -S "${SRC_DIR}" -B build-samples -G Ninja \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DBOX3D_SAMPLES=ON \
  -DBOX3D_UNIT_TESTS=OFF \
  -DBOX3D_BENCHMARKS=OFF \
  -DBOX3D_DOCS=OFF \
  -DBOX3D_PROFILE=OFF \
  -DBOX3D_VALIDATE=OFF \
  -DBOX3D_BUILD_SHADERS=OFF

cmake --build build-samples --config Release --parallel "${CPU_COUNT}"
cmake --install build-samples --config Release

install -d "${PREFIX}/bin"
install -m 755 build-samples/bin/samples "${PREFIX}/bin/box3d-samples"
