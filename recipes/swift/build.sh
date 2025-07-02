#!/bin/bash

set -ex

# Get the version from the recipe context
VERSION="${PKG_VERSION}"

echo "Installing Swift ${VERSION} toolchain..."

# Set up environment for proper linking
export LIBRARY_PATH="${CONDA_BUILD_SYSROOT}/usr/lib64:${CONDA_BUILD_SYSROOT}/usr/lib:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${CONDA_BUILD_SYSROOT}/usr/lib64:${CONDA_BUILD_SYSROOT}/usr/lib:${LD_LIBRARY_PATH}"
export CPATH="${CONDA_BUILD_SYSROOT}/usr/include:${CPATH}"

# Debug: Show current directory and contents
echo "Current directory: $PWD"
echo "Directory contents:"
ls -la

# Debug: Show environment variables
echo "CONDA_BUILD_SYSROOT: $CONDA_BUILD_SYSROOT"
echo "LIBRARY_PATH: $LIBRARY_PATH"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"

# Check if swift directory exists, if not, look for it or create the structure
if [ ! -d "swift" ]; then
    echo "Swift directory not found, checking for alternative locations..."

    # Look for swift source in common locations
    if [ -d "swift-${VERSION}-RELEASE" ]; then
        echo "Found swift-${VERSION}-RELEASE, creating symlink..."
        ln -sf "swift-${VERSION}-RELEASE" swift
    elif [ -d "swift-swift-${VERSION}-RELEASE" ]; then
        echo "Found swift-swift-${VERSION}-RELEASE, creating symlink..."
        ln -sf "swift-swift-${VERSION}-RELEASE" swift
    else
        echo "Swift source not found in expected locations. Available directories:"
        ls -la
        exit 1
    fi
fi

# Verify swift directory exists now
if [ ! -d "swift" ]; then
    echo "Swift directory still not found after setup attempts"
    exit 1
fi

echo "Using Swift source directory: $(readlink -f swift)"

# Change to swift directory and run the build
cd swift

echo "Starting Swift build with preset: buildbot_linux,no_test"
echo "Install destination: $PREFIX"

# Run the Swift build-script with the Fedora preset
# Use the correct argument syntax based on the error message
./utils/build-script \
    --preset=buildbot_linux,no_test \
    install_destdir="$PREFIX" \
    installable_package="$PREFIX"

echo "Swift build completed successfully"
