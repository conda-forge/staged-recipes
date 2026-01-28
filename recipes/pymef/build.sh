#!/bin/bash
set -ex

# The meflib source is extracted to meflib_src/meflib-<commit>/
# We need to copy it to meflib/ where setup.py expects it
cp -r meflib_src/meflib-*/meflib meflib/

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
