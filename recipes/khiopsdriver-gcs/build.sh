#!/bin/bash

# Set-up the shell to behave more like a general-purpose programming language
set -euo pipefail

# Configure project
cmake --fresh -G Ninja -D CMAKE_BUILD_TYPE=Release -D VCPKG_BUILD_TYPE=release -D CMAKE_TOOLCHAIN_FILE=vcpkg/scripts/buildsystems/vcpkg.cmake -B builds/conda -S .

# Build
cmake --build builds/conda --target khiopsdriver_file_gcs

# Copy binary to conda package
cmake --install builds/conda --prefix $PREFIX
