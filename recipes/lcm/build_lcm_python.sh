#!/bin/bash
set -euxo pipefail

# Build only the Python bindings, against the installed liblcm-devel.
cmake -S lcm-python -B build-python -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DPython_EXECUTABLE="${PYTHON}" \
  -DPython3_EXECUTABLE="${PYTHON}" \
  -DLCM_PYTHON_INSTALL_METADATA=ON \
  -DLCM_PYTHON_METADATA_INSTALLER=conda

cmake --build build-python --parallel ${CPU_COUNT}
cmake --install build-python
