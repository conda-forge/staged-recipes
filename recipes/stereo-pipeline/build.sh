#!/bin/bash

# Fetch visionworkbench
cd $SRC_DIR
wget https://github.com/visionworkbench/visionworkbench/archive/refs/tags/3.5.1.tar.gz > /dev/null 2>&1 # this is verbose
tar xzf 3.5.1.tar.gz

echo List all files
ls -d *

cd visionworkbench-3.5.1

# Build visionworkbench
mkdir build
cd build
cmake ..                                         \
    -DCMAKE_PREFIX_PATH=${PREFIX}                \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
    -DASP_DEPS_DIR=${PREFIX}                     \
    -DCMAKE_VERBOSE_MAKEFILE=ON
make -j${CPU_COUNT}
make install

# # Fetch stereo-pipeline
# cd $SRC_DIR
# wget https://github.com/NeoGeographyToolkit/StereoPipeline/archive/refs/tags/3.5.0_minimal.tar.gz > /dev/null 2>&1 # this is verbose
# tar xzf 3.5.0_minimal.tar.gz
# echo List all files
# ls -d *

# cd $SRC_DIR

# # Build visionworkbench
# mkdir build
# cd build
# cmake ..                                         \
#     -DCMAKE_PREFIX_PATH=${PREFIX}                \
#     -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
#     -DASP_DEPS_DIR=${PREFIX}                     \
#     -DCMAKE_VERBOSE_MAKEFILE=ON
# make -j${CPU_COUNT}
# make install

cd $SRC_DIR

# Build stereo-pipeline
# cd StereoPipeline-3.5.0_minimal
mkdir build
cd build
cmake ..                                         \
    -DCMAKE_PREFIX_PATH=${PREFIX}                \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
    -DASP_DEPS_DIR=${PREFIX}                     \
    -DCMAKE_VERBOSE_MAKEFILE=ON
make -j${CPU_COUNT}
make install
