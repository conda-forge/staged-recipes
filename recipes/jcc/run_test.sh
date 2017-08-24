#!/bin/bash

export JCC_JDK=$PREFIX
export JAVA_HOME=$JCC_JDK
export JAVAHOME=$JCC_JDK

$PYTHON test/myrun_test.py

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
