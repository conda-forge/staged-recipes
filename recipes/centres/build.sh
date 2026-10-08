#!/usr/bin/env bash
set -euxo pipefail

# Install the jar at a path that does not change between versions.
mkdir -p "${PREFIX}/share/centres" "${PREFIX}/bin"
cp centres.jar "${PREFIX}/share/centres/centres.jar"

# Command wrappers: bash for Linux and macOS, batch for Windows.
cp "${RECIPE_DIR}/centres" "${PREFIX}/bin/centres"
chmod 0755 "${PREFIX}/bin/centres"
cp "${RECIPE_DIR}/centres.bat" "${PREFIX}/bin/centres.bat"

# The licence texts are fetched as sources into licenses/ (see recipe.yaml).
find licenses -type f | sort
