#!/bin/bash

set -euxo pipefail

rm -rf build || true


CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release"
CMAKE_FLAGS+=" -DPython3_EXECUTABLE=${PYTHON}"
CMAKE_FLAGS+=" -DOPENMM_DIR=${PREFIX}"


mkdir build && cd build
cmake ${CMAKE_FLAGS} ${SRC_DIR}
make -j$CPU_COUNT
make -j$CPU_COUNT install PythonInstall

# Copy tests to the share folder
# Include test executables too
TEST_DIR="${PREFIX}/share/${PKG_NAME}/tests/"

mkdir -p "${TEST_DIR}"
cp -a ../python/tests/* tests/Test* "${TEST_DIR}"
if [[ "$target_platform" == osx* ]]; then
    find "${TEST_DIR}" -name "Test*" -perm +0111 -type f \
        -exec python $RECIPE_DIR/patch_osx_tests.py "{}" \; \
        -exec cp "{}" $PREFIX/share/openmm-xtb/tests/ \;
else
    find "${TEST_DIR}" -name "Test*" -executable -type f -exec cp "{}" $PREFIX/share/openmm-xtb/tests/ \;
fi
