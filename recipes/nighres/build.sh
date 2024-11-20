#!/usr/bin/env bash

# Set Java environment variables
export JAVA_HOME="$BUILD_PREFIX"
export PATH="$JAVA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$JAVA_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH"
export JCC_JDK="$BUILD_PREFIX"

# Run the build script
./build.sh

# Install with pip
$PYTHON -m pip install .

patchelf --set-rpath $PREFIX/jre/lib/amd64/server $PREFIX/lib/python3.10/site-packages/nighresjava/_nighresjava.so

