#!/bin/bash

set -ex # Abort on error.

# Copy the CMakefile to the current directory
cp ${RECIPE_DIR}/CMakeLists.txt ${SRC_DIR}/

# Create an navigate to an out of source build directory
mkdir build
cd build

# Configure the project using CMake
cmake -GNinja \
    ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    ${SRC_DIR}

# Build and install the project
cmake --build . -j ${CPU_COUNT}
cmake --build . --target install
