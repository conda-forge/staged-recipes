#!/usr/bin/env bash

# Clone the nighres repository
git clone https://github.com/nighres/nighres /tmp/nighres
cd /tmp/nighres

# Set JCC_JDK to the Java path in the conda environment
export JCC_JDK="${CONDA_PREFIX}/bin"

# Ensure the JVM shared library is in the library path
export LD_LIBRARY_PATH="${CONDA_PREFIX}/jre/lib/amd64/server:$LD_LIBRARY_PATH"

# Run the build script
./build.sh

# Install with pip
python3 -m pip install .
