#!/usr/bin/env bash
set -ex

# Create the target bin directory inside the conda environment
mkdir -p "$PREFIX/bin"

# Copy all git-extras commands (files starting with git-)
cp git-* "$PREFIX/bin"

# Ensure they are executable
chmod +x "$PREFIX/bin"/git-*
