#!/usr/bin/env bash
set -euxo pipefail

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" && "${CROSSCOMPILING_EMULATOR:-}" == "" ]]; then
    BUILD_TESTING=OFF
else
    BUILD_TESTING=ON
fi

cmake ${CMAKE_ARGS} \
    -S "${SRC_DIR}" \
    -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DHiggsTools_FETCH_DEPENDENCIES=OFF \
    -DHiggsTools_BUILD_SHARED_LIBS=ON \
    -DHiggsTools_BUILD_PYTHON_MODULE=OFF \
    -DHiggsTools_BUILD_MATHEMATICA_INTERFACE=OFF \
    -DHiggsTools_BUILD_EXAMPLES=OFF \
    -DHiggsTools_BUILD_TESTING="${BUILD_TESTING}"

cmake --build build --parallel "${CPU_COUNT}"

if [[ "${BUILD_TESTING}" == "ON" ]]; then
    ctest --test-dir build --output-on-failure --parallel "${CPU_COUNT}"
fi

cmake --install build
