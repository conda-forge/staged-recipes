#!/bin/bash

# -e: Exit the script if any command fails.
# -x: Print each command before running it.
set -ex

# Creates the directory if it doesn’t exist.
mkdir -p build
cd build

# Set OpenMP flags based on platform
if [[ "$(uname)" == "Darwin" ]]; then
  export CXXFLAGS="${CXXFLAGS} -Xpreprocessor -fopenmp"
  export LDFLAGS="${LDFLAGS} -lomp"
else
    export CXXFLAGS="${CXXFLAGS} -fopenmp"
    export LDFLAGS="${LDFLAGS} -fopenmp"
fi

# Configure and build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX

# Compile using all available CPUs
cmake --build . --parallel ${CPU_COUNT}

cmake --install .

# Find the built .so file — it should be somewhere in build/libpython or similar
SO_FILE=$(find . -name "am3*.so" | head -n 1)

# Copy it to site-packages manually using SP_DIR
cp "$SO_FILE" "$SP_DIR/am3.so"

if [[ "$target_platform" == osx-* ]]; then
    echo "Fixing rpath on macOS..."
    install_name_tool -change libam3.dylib @loader_path/libam3.dylib $SP_DIR/am3/am3.so
fi
