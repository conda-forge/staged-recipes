#!/bin/bash

set -euxo pipefail

if [[ $target_platform == osx-* ]]; then
    mkdir -p distrib/meshlab.app/MacOS
    mkdir -p distrib/meshlab.app/Contents/Resources
fi

cmake ${SRC_DIR} \
    ${CMAKE_ARGS} \
    -DALLOW_OPTIONAL_EXTERNAL_MESHLAB_LIBRARIES=ON \
    -DBUILD_BUNDLED_SOURCES_WITHOUT_WARNINGS=OFF \
    -DMESHLAB_BUILD_MINI=ON \
    -DMESHLAB_USE_DEFAULT_BUILD_AND_INSTALL_DIRS=OFF \
    -DMESHLAB_BUILD_DISTRIB_DIR=./distrib \
    -DMESHLAB_LIB_OUTPUT_DIR=./distrib \
    -DMESHLAB_PLUGIN_OUTPUT_DIR=./distrib/plugins \
    -DMESHLAB_SHADER_OUTPUT_DIR=./distrib/shaders \
    -DMESHLAB_BIN_INSTALL_DIR=${PREFIX}/bin \
    -DMESHLAB_LIB_INSTALL_DIR=${PREFIX}/lib \
    -DCMAKE_INSTALL_DATAROOTDIR=${PREFIX}/share \
    -DMESHLAB_PLUGIN_INSTALL_DIR=${PREFIX}/share/meshlab/plugins \
    -DMESHLAB_SHADER_INSTALL_DIR=${PREFIX}/share/meshlab/shaders

make
make install
