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

# Copy the built shared library into the Python package directory
cp cmake-build-local/DearPyGui/_dearpygui* DearPyGui/

# Patch setup.py to skip its own CMake build since we already built above
sed -i "s/self.run_command('dpg_build')/pass  # skipped/" setup.py

${PYTHON} -m pip install . --no-deps --no-build-isolation
