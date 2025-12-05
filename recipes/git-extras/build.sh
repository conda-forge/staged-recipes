#!/usr/bin/env bash
set -ex

# We are already in the source directory ($SRC_DIR)
# Install all git-extras scripts into the conda environment

mkdir -p "$PREFIX/bin"

# Copy all commands that start with 'git-'
cp git-* "$PREFIX/bin/"

# Make them executable
chmod +x "$PREFIX/bin"/git-*
