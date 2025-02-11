#!/bin/bash

# Set-up the shell to behave more like a general-purpose programming language
set -euo pipefail

# Configure project
cmake -B build/conda -S . -D BUILD_JARS=OFF -D TESTING=OFF -D CMAKE_BUILD_TYPE=Release -G Ninja

# Build MODL and MODL_Coclustering
cmake --build build/conda --parallel --target MODL MODL_Coclustering KhiopsNativeInterface _khiopsgetprocnumber

# Move the binaries to the Conda PREFIX path
mv ./build/conda/bin/MODL* "$PREFIX/bin"
mv ./build/conda/bin/_khiopsgetprocnumber* "$PREFIX/bin"
mv ./build/conda/lib/libKhiopsNativeInterface* "$PREFIX/lib"

# Copy the scripts to the Conda PREFIX path
cp ./build/conda/tmp/khiops_env "$PREFIX/bin"
cp ./packaging/linux/common/khiops "$PREFIX/bin"
cp ./packaging/linux/common/khiops_coclustering "$PREFIX/bin"
