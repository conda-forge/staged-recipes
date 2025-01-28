#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Update the submodule to the latest commit CMakeLists.txt
cp ${RECIPE_DIR}/patches/Cores-CMakeLists.txt ${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/CMakeLists.txt
cp ${RECIPE_DIR}/patches/tlib-CMakeLists.txt ${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/tlib/CMakeLists.txt

chmod +x build.sh tools/building/check_weak_implementations.sh
./build.sh --tlib-only --net --no-gui

# Install procedure into a conda path that renode-cli can retrieve
ROOT_PATH="$(cd $(dirname $0); echo $PWD)"
CONFIGURATION="Release"
CORES_PATH="$ROOT_PATH/src/Infrastructure/src/Emulator/Cores"
CORES_BIN_PATH="$CORES_PATH/bin/$CONFIGURATION"

mkdir -p "${PREFIX}/lib/${PKG_NAME}"
tar -c -C "${CORES_BIN_PATH}/lib" . | tar -x -C "${PREFIX}/lib/${PKG_NAME}"
