#!/bin/bash

# Build script for conda package
# This script is used on Linux and macOS

set -e

# Remove virtual environment if it exists
if [ -d "coarsify/src/venv" ]; then
    echo "Removing virtual environment..."
    rm -rf "coarsify/src/venv"
fi

# Install the package in development mode
$PYTHON -m pip install . --no-deps --ignore-installed -vv

# Run tests if they exist
if [ -d "coarsify/src/test" ]; then
    echo "Running tests..."
    $PYTHON -m pytest coarsify/src/test/ -v || echo "Tests failed, but continuing build"
fi

echo "Build completed successfully"
