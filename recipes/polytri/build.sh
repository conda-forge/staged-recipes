#!/bin/bash

set -e

# Set environment variables for Rust build
export CARGO_TARGET_DIR="${SRC_DIR}/rust/target/conda"
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1

# Ensure we're in the source directory
cd "${SRC_DIR}"

# Change to rust directory for building
cd rust

# Build with maturin
echo "Building Rust extension with maturin..."
maturin build --release --features python --out dist

# Install the wheel
echo "Installing built wheel..."
${PYTHON} -m pip install dist/*.whl --no-deps --ignore-installed -vv

# Copy Python package files to site-packages
echo "Installing Python package files..."
PYTHON_SITE_PACKAGES=$(${PYTHON} -c "import site; print(site.getsitepackages()[0])")
mkdir -p "${PYTHON_SITE_PACKAGES}/polytri"
cp -r "${SRC_DIR}/polytri"/* "${PYTHON_SITE_PACKAGES}/polytri/"

# Verify installation
echo "Verifying installation..."
${PYTHON} -c "import polytri; print(f'polytri imported successfully, Rust available: {polytri._rust_available}')"

echo "Build completed successfully!"

