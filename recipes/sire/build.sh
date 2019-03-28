#!/usr/bin/env bash

# Build script for Sire Conda installation.

set -x -e

# Copy the contents of the extracted source archive into the Conda environment.

cp -r bin ${PREFIX}
cp -r include ${PREFIX}
cp -r lib ${PREFIX}
cp -r share ${PREFIX}
