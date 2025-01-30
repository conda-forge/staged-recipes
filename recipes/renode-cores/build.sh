#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Update the submodule to the latest commit CMakeLists.txt
cp ${RECIPE_DIR}/patches/Cores-CMakeLists.txt ${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/CMakeLists.txt
cp ${RECIPE_DIR}/patches/tlib-CMakeLists.txt ${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/tlib/CMakeLists.txt

chmod +x build.sh tools/building/check_weak_implementations.sh
${RECIPE_DIR}/helpers/renode_build_with_cmake.sh --tlib-only --net --no-gui

# Install procedure into a conda path that renode-cli can retrieve
CONFIGURATION="Release"
CORES_PATH="${SRC_DIR}/src/Infrastructure/src/Emulator/Cores"
CORES_BIN_PATH="$CORES_PATH/bin/$CONFIGURATION"

mkdir -p "${PREFIX}/lib/${PKG_NAME}"
tar -c -C "${CORES_BIN_PATH}/lib" . | tar -x -C "${PREFIX}/lib/${PKG_NAME}"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
  mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
  cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}-${CHANGE}.sh"
done