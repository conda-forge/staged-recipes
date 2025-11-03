#!/bin/bash

# We need to ensure setuptools_scm works correctly
# Since we're building from PyPI source tarball, not git, we need to handle versioning
# The tarball should already have the version file generated

set -e

$PYTHON -m pip install . --no-deps --ignore-installed -vv

