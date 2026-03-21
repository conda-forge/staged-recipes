#!/bin/bash
set -ex

mkdir -p cmake-build-local
cd cmake-build-local

cmake .. \
    -DMVDIST_ONLY=True \
    -DMVDPG_VERSION="${PKG_VERSION}" \
    -DMV_PY_VERSION="${PY_VER}" \
    -DCMAKE_BUILD_TYPE=Release \
    ${CMAKE_ARGS}

cd ..
cmake --build cmake-build-local --config Release

${PYTHON} -m pip install . --no-deps --no-build-isolation
