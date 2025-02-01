#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Update the submodule CMakeLists.txt with a recent version (post-CMake conversion)
CMAKEFILES_TXT="src/Emulator/Cores/CMakeLists.txt"
cp "cmake-renode-infrastructure/${CMAKEFILES_TXT}" "${SRC_DIR}/src/Infrastructure/${CMAKEFILES_TXT}"
cp cmake-tlib/CMakeLists.txt "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/tlib"
cp cmake-tlib/tcg/CMakeLists.txt "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/tlib/tcg"

cp cmake-tlib/LICENSE "${RECIPE_DIR}/tlib-LICENSE"
cp "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/tlib/softfloat-3/COPYING.txt" "${RECIPE_DIR}/softfloat-3-COPYING.txt"

chmod +x build.sh tools/building/check_weak_implementations.sh
${RECIPE_DIR}/helpers/renode_build_with_cmake.sh

# Install procedure into a conda path that renode-cli can retrieve
CONFIGURATION="Release"
CORES_PATH="${SRC_DIR}/src/Infrastructure/src/Emulator/Cores"
CORES_BIN_PATH="$CORES_PATH/bin/$CONFIGURATION"

mkdir -p "${PREFIX}/lib/${PKG_NAME}"
tar -c -C "${CORES_BIN_PATH}/lib" . | tar -x -C "${PREFIX}/lib/${PKG_NAME}"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
# for CHANGE in "activate" "deactivate"
# do
#   mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
#   cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}-${CHANGE}.sh"
# done