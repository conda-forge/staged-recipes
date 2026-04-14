#!/bin/bash
set -euxo pipefail

# Step 1: Build the Java JAR with Maven
cd "${SRC_DIR}/java"
mvn package -DskipTests -q

# Step 2: Install the Python wrapper (hatch_build.py will find the JAR)
cd "${SRC_DIR}/python/opendataloader-pdf"
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
