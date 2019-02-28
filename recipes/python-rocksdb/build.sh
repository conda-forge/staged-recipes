#!/bin/bash

export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:$PREFIX/include
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$PREFIX/lib
export LIBRARY_PATH=${LIBRARY_PATH}:$PREFIX/lib
$PYTHON setup.py install 

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
