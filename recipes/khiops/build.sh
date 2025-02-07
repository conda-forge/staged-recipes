#!/bin/bash

# Set-up the shell to behave more like a general-purpose programming language
set -euo pipefail

# Configure project
cmake -B conda-build -S . -D BUILD_JARS=OFF -D TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER -G Ninja

# Build MODL and MODL_Coclustering
cmake --build conda-build --parallel --target MODL MODL_Coclustering KhiopsNativeInterface _khiopsgetprocnumber

# Move the binaries to the Conda PREFIX path
mv ./conda-build/bin/MODL* "$PREFIX/bin"
mv ./conda-build/bin/_khiopsgetprocnumber* "$PREFIX/bin"
mv ./conda-build/lib/libKhiopsNativeInterface* "$PREFIX/lib"

# Copy the scripts to the Conda PREFIX path
cp ./conda-build/tmp/khiops_env "$PREFIX/bin"
cp ./packaging/linux/common/khiops "$PREFIX/bin"
cp ./packaging/linux/common/khiops_coclustering "$PREFIX/bin"
