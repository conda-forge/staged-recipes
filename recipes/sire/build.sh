#!/usr/bin/env bash

# Build script for Sire Conda installation.

set -x -e

# Move the contents of the extracted source archive into place.

mv bin ${PREFIX}
mv lib ${PREFIX}
mv pkgs ${PREFIX}
