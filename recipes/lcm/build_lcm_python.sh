#!/bin/bash
set -euxo pipefail

# Configure the full project (the extension module links the in-tree static
# liblcm, as upstream does), but only build and install the Python module.
cmake -S . -B build-python -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DLCM_ENABLE_EXAMPLES=OFF \
  -DLCM_ENABLE_TESTS=OFF \
  -DLCM_ENABLE_PYTHON=ON \
  -DLCM_ENABLE_JAVA=OFF \
  -DLCM_ENABLE_LUA=OFF \
  -DLCM_ENABLE_GO=OFF \
  -DCMAKE_DISABLE_FIND_PACKAGE_Java=ON \
  -DCMAKE_DISABLE_FIND_PACKAGE_Lua=ON \
  -DCMAKE_DISABLE_FIND_PACKAGE_Go=ON \
  -DPython_EXECUTABLE="${PYTHON}" \
  -DPython3_EXECUTABLE="${PYTHON}" \
  -DDOXYGEN_EXECUTABLE=DOXYGEN_EXECUTABLE-NOTFOUND \
  -DSPHINX_EXECUTABLE=SPHINX_EXECUTABLE-NOTFOUND

cmake --build build-python --parallel ${CPU_COUNT} \
  --target lcm-python lcm-python-init lcm-python-stub lcm-python-typed
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -P build-python/lcm-python/cmake_install.cmake
