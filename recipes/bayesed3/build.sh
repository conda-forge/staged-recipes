#!/bin/bash
set -e

# Install Python package WITH dependencies
# Dependencies are read from pyproject.toml
$PYTHON -m pip install . --ignore-installed -vv

# Create share directory for data files
mkdir -p $PREFIX/share/bayesed3

# Copy binaries
# Note: Source is a GitHub release tarball which only contains git-tracked files
if [ "$(uname)" == "Linux" ]; then
  if [ -d "bin/linux" ]; then
    mkdir -p $PREFIX/share/bayesed3/bin/linux
    cp -r bin/linux/* $PREFIX/share/bayesed3/bin/linux/
  fi
elif [ "$(uname)" == "Darwin" ]; then
  if [ -d "bin/mac" ]; then
    mkdir -p $PREFIX/share/bayesed3/bin/mac
    cp -r bin/mac/* $PREFIX/share/bayesed3/bin/mac/
  fi
fi

# Copy data directories
# Note: Only git-tracked files are in the tarball, so this is safe
for dir in models nets data filters observation papers docs plot tools; do
  if [ -d "$dir" ]; then
    cp -r "$dir" $PREFIX/share/bayesed3/
  fi
done
