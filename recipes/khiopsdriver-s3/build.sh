#!/bin/bash

# Set-up the shell to behave more like a general-purpose programming language
set -euo pipefail
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# Configure project
cmake --fresh ${CMAKE_ARGS} -G Ninja -D CMAKE_BUILD_TYPE=Release -D S3_PLUGIN_BUILD_ENV=conda -B builds/conda -S .

# Build
cmake --build builds/conda --target khiopsdriver_file_s3

# Copy binary to conda package
cmake --install builds/conda --prefix $PREFIX
