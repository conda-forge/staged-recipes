#!/usr/bin/env bash

# Build script for Sire Conda installation.

set -x -e

# Copy the contents of the extracted source archive into the Conda environment.

cp -a bin ${PREFIX}
cp -a include ${PREFIX}
cp -a lib ${PREFIX}
cp -a share ${PREFIX}
