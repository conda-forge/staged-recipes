#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status
set -x # Print commands and their arguments as they are executed

WORKING_DIR="./icechunk-python"
DIST_DIR="$WORKING_DIR/dist"
MANYLINUX="auto"     # Update based on the target platform if needed
TARGET="$(uname -m)" # Get architecture (e.g., x86_64, armv7, aarch64)

# Create a clean dist directory
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Ensure Python version
python3 --version

# Build wheels
echo "Building wheels for target: $TARGET"
maturin build --release --out "$DIST_DIR" --find-interpreter --manylinux "$MANYLINUX"

# Build sdist
echo "Building source distribution..."
maturin sdist --out "$DIST_DIR"

echo "Build complete. Artifacts available in $DIST_DIR"
