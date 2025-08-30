#!/bin/bash
set -ex

# Set environment variables for HDF5 and other dependencies
export HDF5_DIR=$PREFIX
export GSL_DIR=$PREFIX
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH

# Configure meson to use conda environment paths
export CFLAGS="-I$PREFIX/include $CFLAGS"
export CXXFLAGS="-I$PREFIX/include $CXXFLAGS"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib $LDFLAGS"

# Debug information
echo "Using Python: $PYTHON"
$PYTHON --version
echo "PREFIX: $PREFIX"
echo "SP_DIR: $SP_DIR"

# Try pip install with config settings first
echo "Attempting pip install with config settings..."
if $PYTHON -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++20 -Duse_hdf5=true"; then
    echo "Pip install with config settings succeeded"
elif $PYTHON -m pip install . --no-deps -vv --no-build-isolation; then
    echo "Pip install without build isolation succeeded"
else
    echo "Both pip methods failed, trying fallback approach"
    # Fallback to direct meson build
    meson setup --wipe _build --prefix=$PREFIX --buildtype=release -Duse_mpi=false -Duse_hdf5=true
    meson compile -vC _build
    meson install -C _build
fi

# Verify installation
if [ -d "$SP_DIR/moose" ]; then
    echo "SUCCESS: MOOSE installed to $SP_DIR/moose"
    ls -la "$SP_DIR/moose"
else
    echo "ERROR: MOOSE not found in $SP_DIR"
    echo "Contents of SP_DIR:"
    ls -la "$SP_DIR" || echo "SP_DIR does not exist"
    exit 1
fi
