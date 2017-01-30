#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
conda upgrade -y -q gdal

# As of 01/30/2017, on macOS with the conda-forge channel ahead of the default
# channel in ~/.condarc, the version of gdal that gets installed by the first
# setup.py line will fail with an error that it can't find libgdal.20.dylib.
# However, upgrading gdal to the latest version fixes this issue.

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
