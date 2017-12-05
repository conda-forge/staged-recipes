#!/bin/bash

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX $SRC_DIR 
make install

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
