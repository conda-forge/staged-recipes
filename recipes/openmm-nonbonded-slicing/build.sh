#!/bin/bash

set -euxo pipefail

rm -rf build || true

CMAKE_FLAGS="-DOPENMM_DIR=${PREFIX}"
if [[ "$target_platform" == osx* ]]; then
    CMAKE_FLAGS+=" -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
    CMAKE_FLAGS+=" -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
fi

# Build in subdirectory and install.
mkdir -p build
cd build
cmake ${CMAKE_ARGS} ${CMAKE_FLAGS} ${SRC_DIR}
make -j$CPU_COUNT install
make -j$CPU_COUNT PythonInstall

# Include test executables too
mkdir -p ${PREFIX}/share/openmm-nonbonded-slicing/tests
if [[ "$target_platform" == osx* ]]; then
    find . -name "Test*" -perm +0111 -type f \
        -exec python $RECIPE_DIR/patch_osx_tests.py "{}" \; \
        -exec cp "{}" $PREFIX/share/openmm-nonbonded-slicing/tests/ \;
else
    find . -name "Test*" -executable -type f -exec cp "{}" $PREFIX/share/openmm-nonbonded-slicing/tests/ \;
fi
