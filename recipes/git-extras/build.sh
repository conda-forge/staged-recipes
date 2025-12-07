#!/usr/bin/env bash
set -ex

cd "$SRC_DIR"

# Use the official installer provided by git-extras
bash install.sh "$PREFIX"
