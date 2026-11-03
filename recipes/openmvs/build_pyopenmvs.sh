#!/bin/bash
set -euxo pipefail

# OpenMVS keeps state in function-local statics of inline functions; with
# shared libraries, -fvisibility-inlines-hidden gives every library its own
# copy (patch 0005 fixes the logger, which made the tools print nothing).
export CXXFLAGS="${CXXFLAGS//-fvisibility-inlines-hidden/}"

# Build only the pyOpenMVS module, against the openmvs package in $PREFIX
# through find_package(OpenMVS) (see pyopenmvs/CMakeLists.txt).
cmake -S $RECIPE_DIR/pyopenmvs -B build-py -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DPython3_EXECUTABLE=$PYTHON \
  -DOPENMVS_SOURCE_DIR=$SRC_DIR
cmake --build build-py --parallel ${CPU_COUNT}
cmake --install build-py
