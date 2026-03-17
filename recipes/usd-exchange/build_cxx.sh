#!/usr/bin/env bash
set -euxo pipefail

cp "${RECIPE_DIR}/cxx/CMakeLists.txt" "${SRC_DIR}/CMakeLists.txt"
cp -r "${RECIPE_DIR}/cxx/cmake" "${SRC_DIR}/cmake"

cmake -S "${SRC_DIR}" -B build -G Ninja \
  ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DUSDEX_VERSION="${PKG_VERSION}" \
  -DUSDEX_BUILD_STRING="${PKG_VERSION}" \
  -DBUILD_TESTING=ON

cmake --build build -j"${CPU_COUNT}"

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
    ctest --test-dir build --output-on-failure
fi

cmake --install build
