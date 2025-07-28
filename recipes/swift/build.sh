#!/bin/bash

set -ex

# Get the version from the recipe context
VERSION="${PKG_VERSION}"

echo "Installing Swift ${VERSION} toolchain..."

# Debug: Show current directory and contents
echo "Current directory: $PWD"
echo "Directory contents:"
ls -la

# Ensure runtime libraries are available for cross-compilation
export LIBRARY_PATH="$BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64:$BUILD_PREFIX/lib/gcc/x86_64-conda-linux-gnu/14.3.0:$BUILD_PREFIX/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64:$BUILD_PREFIX/lib/gcc/x86_64-conda-linux-gnu/14.3.0:$BUILD_PREFIX/lib:$LD_LIBRARY_PATH"

# Debug: Show the configured toolchain
echo "Configured toolchain:"
echo "  CC                 : $CC"
echo "  CXX                : $CXX"
echo "  LD                 : $LD"
echo "  AR                 : $AR"
echo "  SYSROOT            : $CONDA_BUILD_SYSROOT"
echo "  LIBRARY_PATH       : $LIBRARY_PATH"
echo "  LD_LIBRARY_PATH    : $LD_LIBRARY_PATH"
echo "  CONDA_BUILD_SYSROOT: $CONDA_BUILD_SYSROOT"

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
    installable_package="$PREFIX/swift-${VERSION}-RELEASE.tar.gz"

echo "Swift build completed successfully"
