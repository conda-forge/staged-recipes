#!/usr/bin/env bash
set -ex

# Move into source directory (conda-build already does this)
# Install scripts
mkdir -p "$PREFIX/bin"
cp git-* "$PREFIX/bin"
chmod +x "$PREFIX/bin"/git-*
