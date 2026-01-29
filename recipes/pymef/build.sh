#!/bin/bash
set -ex

# The meflib source is extracted to meflib_src/ (conda-build strips the top-level dir)
# setup.py expects include_dirs=["meflib/meflib"], so we need meflib/meflib/
# The pymef tarball has an empty meflib/ dir (submodule placeholder)
# Copy the meflib subdirectory into meflib/ to create the nested structure
mkdir -p meflib/meflib
cp -r meflib_src/meflib/* meflib/meflib/

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
