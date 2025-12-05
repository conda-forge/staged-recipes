#!/usr/bin/env bash
set -ex

# Enter the extracted source directory automatically
cd "$SRC_DIR"/*/

# Install all git-extras scripts
mkdir -p "$PREFIX/bin"
cp git-* "$PREFIX/bin"
chmod +x "$PREFIX/bin"/git-*
