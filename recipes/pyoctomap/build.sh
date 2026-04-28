#!/bin/bash
set -ex

# The PyPI tarball has a partial src/octomap directory (headers only).
# We replace it with the full source we downloaded.
rm -rf src/octomap
mv octomap_repo src/octomap

# The CI script attempts to copy .so files to /usr/local/lib on Linux.
# In a conda build environment, we don't have root, and we want them in ${PREFIX}/lib.
# We patch the script to use ${PREFIX}/lib instead.
if [ "$(uname -s)" == "Linux" ]; then
  sed -i.bak 's|/usr/local/lib|'"${PREFIX}"'/lib|g' scripts/ci/build_octomap.sh
fi

# Pass CMAKE_ARGS to the cmake call in the CI script for cross-compilation support (macOS/ARM)
sed -i.bak 's|"${CMAKE_BIN}" ..|"${CMAKE_BIN}" ${CMAKE_ARGS} ..|g' scripts/ci/build_octomap.sh

# Build octomap using the provided CI script
bash scripts/ci/build_octomap.sh .

# Ensure all libraries (including macOS .dylib) are copied to the conda environment
cp -a src/octomap/lib/* ${PREFIX}/lib/ || true

# Install the Python package
${PYTHON} -m pip install . -vv
