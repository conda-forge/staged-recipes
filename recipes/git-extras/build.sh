#!/usr/bin/env bash
set -ex

# Install all git-* scripts into $PREFIX/bin
mkdir -p "$PREFIX/bin"

# Copy scripts
cp git-* "$PREFIX/bin"

# Ensure executables
chmod +x "$PREFIX/bin"/git-*
