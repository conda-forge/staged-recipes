#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.

# Install pex using pip
$PYTHON -m pip install pex<3,>=2.1.132

# Install the package itself
$PYTHON -m pip install . -vv --no-deps --no-build-isolation