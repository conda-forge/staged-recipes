#!/bin/bash

set -euo pipefail

# OpenColorIO build script following official installation instructions
# https://opencolorio.readthedocs.io/en/latest/quick_start/installation.html

# Create build directory
mkdir -p build
cd build

# CMake configuration with explicit flags (showing defaults from documentation)
# Common CMake Options:
cmake_args=(
    "-DCMAKE_INSTALL_PREFIX=${PREFIX}"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=ON"

    # OCIO-specific options (defaults shown):
    "-DOCIO_BUILD_APPS=ON"                    # Set to OFF to not build command-line tools
    "-DOCIO_USE_OIIO_FOR_APPS=OFF"            # Set ON to build tools with OpenImageIO rather than OpenEXR
    "-DOCIO_BUILD_PYTHON=ON"                  # Set to OFF to not build the Python binding
    "-DOCIO_BUILD_OPENFX=OFF"                 # Set to ON to build the OpenFX plug-ins
    "-DOCIO_USE_SIMD=ON"                      # Set to OFF to turn off SIMD optimizations
    "-DOCIO_USE_SSE2=ON"                      # Set to OFF to turn off SSE2
    "-DOCIO_USE_AVX=ON"                       # Set to OFF to turn off AVX
    "-DOCIO_USE_AVX2=ON"                      # Set to OFF to turn off AVX2
    "-DOCIO_USE_F16C=ON"                      # Set to OFF to turn off F16C
    "-DOCIO_BUILD_TESTS=OFF"                   # Set to OFF to not build the unit tests
    "-DOCIO_BUILD_GPU_TESTS=OFF"               # Set to OFF to not build the GPU unit tests
    "-DOCIO_USE_HEADLESS=OFF"                 # Set to ON to do headless GPU rendering
    "-DOCIO_WARNING_AS_ERROR=ON"              # Set to OFF to turn off warnings as errors
    "-DOCIO_BUILD_DOCS=OFF"                   # Set to ON to build the documentation

    # Dependency installation strategy (MISSING is the default):
    # NONE: Use system installed packages, fail if missing
    # MISSING: Prefer system, install if missing (DEFAULT)
    # ALL: Install all required packages regardless
    "-DOCIO_INSTALL_EXT_PACKAGES=MISSING"
)

# Configure CMake
cmake "${cmake_args[@]}" ..

# Build (using parallel jobs if available)
if command -v ninja &> /dev/null; then
    cmake --build . -j ${CPU_COUNT:-${NPROCS:-1}}
else
    make -j${CPU_COUNT:-${NPROCS:-1}}
fi

# Install
make install
