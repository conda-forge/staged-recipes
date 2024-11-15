#!/usr/bin/env bash

export PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/bin

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/jvm/java-8-openjdk-amd64/lib

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

export JCC_JDK=/usr/lib/jvm/java-8-openjdk-amd64/

# Run the build script
./build.sh

# Install with pip
python3 -m pip install .