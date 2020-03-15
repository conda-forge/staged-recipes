#!/bin/bash

PIP_NO_CACHE_DIR=True $PYTHON -m pip install --no-deps --no-binary :all: .


# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.